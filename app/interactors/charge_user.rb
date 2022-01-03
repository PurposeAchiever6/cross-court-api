class ChargeUser
  include Interactor

  def call
    user = context.user
    price = context.price
    description = context.description

    unless price.positive?
      context.fail!(message: I18n.t('api.errors.users.charges.price_not_positive'))
    end

    payment_method = StripeService.fetch_payment_methods(user).first

    unless payment_method
      context.fail!(message: I18n.t('api.errors.users.charges.missing_payment_method'))
    end

    payment_intent = StripeService.charge(user, payment_method, price, description)

    context.charge_payment_intent_id = payment_intent.id
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
