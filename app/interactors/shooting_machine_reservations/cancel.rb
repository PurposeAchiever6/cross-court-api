module ShootingMachineReservations
  class Cancel
    include Interactor

    def call
      shooting_machine_reservations = context.shooting_machine_reservations
      shooting_machine_reservations.each(&:canceled!)
    end
  end
end
