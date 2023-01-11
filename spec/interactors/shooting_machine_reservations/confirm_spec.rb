require 'rails_helper'

describe ShootingMachineReservations::Confirm do
  describe '.call' do
    let!(:user) { create(:user, :with_payment_method) }
    let!(:session) { create(:session) }
    let!(:user_session) { create(:user_session, session:, user:) }
    let!(:shooting_machine) { create(:shooting_machine, session:, price:) }
    let!(:shooting_machine_reservation) do
      create(
        :shooting_machine_reservation,
        user_session:,
        shooting_machine:,
        status:
      )
    end

    let(:status) { :reserved }
    let(:price) { rand(50..100) }
    let(:payment_intent_id) { rand(1_000).to_s }

    before { allow(StripeService).to receive(:charge).and_return(double(id: payment_intent_id)) }

    subject do
      ShootingMachineReservations::Confirm.call(
        shooting_machine_reservation:
      )
    end

    it { expect { subject }.to change(Payment, :count).by(1) }

    it 'updates shooting machine reservation status' do
      expect { subject }.to change { shooting_machine_reservation.reload.status }.to('confirmed')
    end

    it 'sets the shooting machine reservation charge payment intent id' do
      expect {
        subject
      }.to change {
        shooting_machine_reservation.reload.charge_payment_intent_id
      }.to(payment_intent_id)
    end

    context 'when the shooting machine reservation is not in reserved status' do
      let(:status) { %i[canceled confirmed].sample }

      it 'raises ShootingMachineReservationNotReservedException' do
        expect {
          subject
        }.to raise_error(
          ShootingMachineReservationNotReservedException,
          'The shooting machine reservation status is not reserved'
        )
      end

      it { expect { subject rescue nil }.not_to change(Payment, :count) }

      it 'does not update shooting machine reservation status' do
        expect { subject rescue nil }.not_to change { shooting_machine_reservation.reload.status }
      end
    end

    context 'when price is zero' do
      let(:price) { 0 }

      it 'does not call StripeService' do
        expect(StripeService).not_to receive(:charge)
        subject
      end

      it { expect { subject }.not_to change(Payment, :count) }

      it 'updates shooting machine reservation status' do
        expect { subject }.to change { shooting_machine_reservation.reload.status }.to('confirmed')
      end

      it 'does not set the shooting machine reservation charge payment intent id' do
        expect {
          subject
        }.not_to change { shooting_machine_reservation.reload.charge_payment_intent_id }
      end
    end

    context 'when the charge fails' do
      let(:error_msg) { 'Some error message' }

      before do
        allow(StripeService).to receive(:charge).and_raise(Stripe::StripeError, error_msg)
        allow_any_instance_of(Slack::Notifier).to receive(:ping)
      end

      it { expect { subject }.to change(Payment, :count).by(1) }

      it 'updates shooting machine reservation status' do
        expect { subject }.to change { shooting_machine_reservation.reload.status }.to('confirmed')
      end

      it 'updates shooting machine reservation error on charge' do
        expect {
          subject
        }.to change { shooting_machine_reservation.reload.error_on_charge }.to(error_msg)
      end

      it 'does not set the shooting machine reservation charge payment intent id' do
        expect {
          subject
        }.not_to change { shooting_machine_reservation.reload.charge_payment_intent_id }
      end
    end
  end
end
