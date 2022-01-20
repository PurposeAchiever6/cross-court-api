class ChargeCanceledOutOfTimeUserSession
  include Interactor

  def call
    user_session = context.user_session
    user = user_session.user

    return if user_session.in_cancellation_time?

    price_to_charge = 0

    if user.unlimited_credits?
      price_to_charge = ENV['UNLIMITED_CREDITS_CANCELED_OUT_OF_TIME_PRICE'].to_f
    elsif user_session.is_free_session
      price_to_charge = ENV['FREE_SESSION_CANCELED_OUT_OF_TIME_PRICE'].to_f
    end

    context.amount_charged = price_to_charge

    return unless price_to_charge.positive?

    result = ChargeUser.call(
      user: user,
      price: price_to_charge,
      description: 'Session canceled out of time fee'
    )

    context.fail!(message: result.message) if result.failure?

    context.charge_payment_intent_id = result.charge_payment_intent_id
  end
end
