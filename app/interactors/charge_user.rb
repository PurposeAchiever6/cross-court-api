class ChargeUser
  include Interactor

  def call
    user = context.user
    price = context.price
    description = context.description

    context.fail!(message: I18n.t('api.errors.users.charges.price_not_positive')) unless price.positive?

    payment_method = StripeService.fetch_payment_methods(user).first

    context.fail!(message: I18n.t('api.errors.users.charges.missing_payment_method')) unless payment_method

    payment_intent = StripeService.charge(user, payment_method, price, description)

    context.charge_payment_intent_id = payment_intent.id
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
