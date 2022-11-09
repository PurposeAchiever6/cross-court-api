require 'rails_helper'

describe ShootingMachineReservations::Create do
  describe '.call' do
    let!(:user) { create(:user, :with_payment_method) }
    let!(:session) { create(:session, is_open_club: open_club) }
    let!(:shooting_machine) { create(:shooting_machine, session: session, price: price) }
    let!(:user_session) { create(:user_session, session: session, user: user) }

    let(:open_club) { true }
    let(:price) { rand(50..100) }
    let(:payment_intent_id) { rand(1_000).to_s }

    before { allow(StripeService).to receive(:charge).and_return(double(id: payment_intent_id)) }

    subject do
      ShootingMachineReservations::Create.call(
        shooting_machine: shooting_machine,
        user_session: user_session
      )
    end

    it { expect { subject }.to change(ShootingMachineReservation, :count).by(1) }

    it { expect { subject }.to change(Payment, :count).by(1) }

    it { expect(subject.shooting_machine_reservation).to eq(ShootingMachineReservation.last) }

    it 'sets the charge payment intent id' do
      expect(subject.shooting_machine_reservation.charge_payment_intent_id).to eq(payment_intent_id)
    end

    context 'when the user session and the shooting machine are for different sessions' do
      before { shooting_machine.update!(session: create(:session)) }

      it 'raises ShootingMachineSessionMismatchException' do
        expect {
          subject
        }.to raise_error(
          ShootingMachineSessionMismatchException,
          'The shooting machine mismatch from the session reservation'
        )
      end

      it { expect { subject rescue nil }.not_to change(ShootingMachineReservation, :count) }

      it { expect { subject rescue nil }.not_to change(Payment, :count) }
    end

    context 'when the session does not allow shooting machines' do
      let(:open_club) { false }

      it 'raises ShootingMachineInvalidSessionException' do
        expect {
          subject
        }.to raise_error(
          ShootingMachineInvalidSessionException,
          'The session does not support a shooting machine'
        )
      end

      it { expect { subject rescue nil }.not_to change(ShootingMachineReservation, :count) }

      it { expect { subject rescue nil }.not_to change(Payment, :count) }
    end

    context 'when the shooting machine has already been reserved' do
      let!(:other_user_session) { create(:user_session, session: session) }
      let!(:shooting_machine_reservation) do
        create(
          :shooting_machine_reservation,
          shooting_machine: shooting_machine,
          user_session: other_user_session
        )
      end

      it 'raises ShootingMachineAlreadyReservedException' do
        expect {
          subject
        }.to raise_error(
          ShootingMachineAlreadyReservedException,
          'The shooting machine has already been reserved'
        )
      end

      it { expect { subject rescue nil }.not_to change(ShootingMachineReservation, :count) }

      it { expect { subject rescue nil }.not_to change(Payment, :count) }
    end

    context 'when the user has a canceled reservation for the shooting machine' do
      let!(:shooting_machine_reservation) do
        create(
          :shooting_machine_reservation,
          shooting_machine: shooting_machine,
          user_session: user_session,
          status: :canceled
        )
      end

      it { expect { subject }.to change(ShootingMachineReservation, :count).by(1) }

      it { expect { subject }.to change(Payment, :count).by(1) }
    end

    context 'when price is zero' do
      let(:price) { 0 }

      it 'does not call StripeService' do
        expect(StripeService).not_to receive(:charge)
        subject
      end

      it { expect { subject }.to change(ShootingMachineReservation, :count).by(1) }

      it { expect { subject }.not_to change(Payment, :count) }
    end
  end
end
