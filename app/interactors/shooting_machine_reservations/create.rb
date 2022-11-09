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

      user = user_session.user
      price = shooting_machine.price
      charge_payment_intent_id = nil

      if price.positive?
        charge_payment_intent_id = Users::Charge.call(
          user: user,
          amount: price,
          description: 'Shooting machine rental',
          raise_error: true
        ).payment_intent_id
      end

      shooting_machine_reservation = ShootingMachineReservation.create!(
        shooting_machine: shooting_machine,
        user_session: user_session,
        charge_payment_intent_id: charge_payment_intent_id
      )

      context.shooting_machine_reservation = shooting_machine_reservation
    end
  end
end
