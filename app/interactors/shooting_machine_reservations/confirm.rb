module ShootingMachineReservations
  class Confirm
    include Interactor

    def call
      shooting_machine_reservations = context.shooting_machine_reservations

      shooting_machine_reservations.each do |shooting_machine_reservation|
        user = shooting_machine_reservation.user
        price = shooting_machine_reservation.price

        unless shooting_machine_reservation.reserved?
          raise ShootingMachineReservationNotReservedException
        end

        if price.positive?
          charge_payment_intent_id = Users::Charge.call(
            user:,
            amount: price,
            description: 'Shooting machine rental',
            use_cc_cash: true,
            notify_error: true,
            create_payment_on_failure: true,
            raise_error: true
          ).payment_intent_id

          shooting_machine_reservation.charge_payment_intent_id = charge_payment_intent_id
        end

        shooting_machine_reservation.status = :confirmed

        shooting_machine_reservation.save!
      rescue ChargeUserException => e
        shooting_machine_reservation.update!(
          status: :confirmed,
          error_on_charge: e.message
        )
      end
    end
  end
end
