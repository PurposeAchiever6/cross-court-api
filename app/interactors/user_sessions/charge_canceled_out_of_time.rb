module UserSessions
  class ChargeCanceledOutOfTime
    include Interactor

    def call
      user_session = context.user_session
      location = user_session.session.location
      user = user_session.user

      return if user_session.in_cancellation_time?

      amount_to_charge = if user_session.is_free_session
                           ENV['FREE_SESSION_CANCELED_OUT_OF_TIME_PRICE'].to_f
                         else
                           location.late_cancellation_fee
                         end

      context.amount_charged = amount_to_charge

      return unless amount_to_charge.positive?

      result = Users::Charge.call(
        user:,
        amount: amount_to_charge,
        description: 'Session canceled out of time fee',
        notify_error: true,
        use_cc_cash: true,
        create_payment_on_failure: true
      )

      context.fail!(message: result.message) if result.failure?

      context.payment_intent_id = result.payment_intent_id
    end
  end
end
