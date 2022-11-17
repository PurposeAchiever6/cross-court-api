module ShootingMachineReservations
  class Cancel
    include Interactor

    def call
      shooting_machine_reservation = context.shooting_machine_reservation
      shooting_machine_reservation.canceled!
    end
  end
end
