class ChargeCard
  include Interactor

  def call
    price = context.price
    user = context.user
    payment_method = user.payment_methods.find(context.payment_method_id)

    return if price.zero?

    payment_intent = StripeService.charge(
      user,
      payment_method.stripe_id,
      price,
      context.description
    )

    context.charge_payment_intent_id = payment_intent.id
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
