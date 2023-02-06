module ShootingMachineReservations
  class Create
    include Interactor

    def call
      shooting_machines = context.shooting_machines

      return if shooting_machines.blank?

      user_session = context.user_session
      session = user_session.session
      date = user_session.date

      context.shooting_machine_reservations = []

      shooting_machines.each do |shooting_machine|
        raise ShootingMachineSessionMismatchException if session.id != shooting_machine.session_id
        raise ShootingMachineInvalidSessionException unless session.shooting_machines?
        raise ShootingMachineAlreadyReservedException if shooting_machine.reserved?(date)

        shooting_machine_reservation = ShootingMachineReservation.create!(
          shooting_machine:,
          user_session:
        )

        context.shooting_machine_reservations << shooting_machine_reservation
      end
    end
  end
end
