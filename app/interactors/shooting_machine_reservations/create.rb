module ShootingMachineReservations
  class Create
    include Interactor

    def call
      shooting_machine = context.shooting_machine

      return unless shooting_machine

      user_session = context.user_session
      session = user_session.session
      date = user_session.date

      raise ShootingMachineSessionMismatchException if session.id != shooting_machine.session_id
      raise ShootingMachineInvalidSessionException unless session.shooting_machines?
      raise ShootingMachineAlreadyReservedException if shooting_machine.reserved?(date)

      shooting_machine_reservation = ShootingMachineReservation.create!(
        shooting_machine: shooting_machine,
        user_session: user_session
      )

      context.shooting_machine_reservation = shooting_machine_reservation
    end
  end
end
