require 'rails_helper'

describe ShootingMachineReservations::Create do
  describe '.call' do
    let!(:user) { create(:user, :with_payment_method) }
    let!(:session) { create(:session, is_open_club: open_club) }
    let!(:shooting_machine) { create(:shooting_machine, session:) }
    let!(:user_session) { create(:user_session, session:, user:) }

    let(:open_club) { true }

    subject do
      ShootingMachineReservations::Create.call(
        shooting_machines: [shooting_machine],
        user_session:
      )
    end

    it { expect { subject }.to change(ShootingMachineReservation, :count).by(1) }

    it { expect(subject.shooting_machine_reservations.last).to eq(ShootingMachineReservation.last) }

    it { expect(subject.shooting_machine_reservations.last.status).to eq('reserved') }

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
    end

    context 'when the shooting machine has already been reserved' do
      let!(:other_user_session) { create(:user_session, session:) }
      let!(:shooting_machine_reservation) do
        create(
          :shooting_machine_reservation,
          shooting_machine:,
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
    end

    context 'when the user has a canceled reservation for the shooting machine' do
      let!(:shooting_machine_reservation) do
        create(
          :shooting_machine_reservation,
          shooting_machine:,
          user_session:,
          status: :canceled
        )
      end

      it { expect { subject }.to change(ShootingMachineReservation, :count).by(1) }
    end
  end
end
