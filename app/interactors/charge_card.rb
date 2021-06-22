class ChargeCard
  include Interactor

  def call
    price = context.price
    return if price.zero?

    payment_intent = StripeService.charge(context.user, context.payment_method, price)

    context.charge_payment_intent_id = payment_intent.id
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
