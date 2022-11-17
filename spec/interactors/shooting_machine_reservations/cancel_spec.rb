require 'rails_helper'

describe ShootingMachineReservations::Cancel do
  describe '.call' do
    let!(:shooting_machine_reservation) { create(:shooting_machine_reservation) }

    subject do
      ShootingMachineReservations::Cancel.call(
        shooting_machine_reservation: shooting_machine_reservation
      )
    end

    it 'updates shooting machine reservation status' do
      expect { subject }.to change { shooting_machine_reservation.reload.status }.to('canceled')
    end
  end
end
