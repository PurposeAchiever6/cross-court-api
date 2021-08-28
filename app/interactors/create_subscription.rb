class CreateSubscription
  include Interactor

  def call
    user = context.user
    product = context.product
    payment_method_id = context.payment_method
    stripe_promo_code_id = context.promo_code&.stripe_promo_code_id

    context.fail!(message: I18n.t('api.errors.subscriptions.user_has_active')) if user.active_subscription

    stripe_subscription = StripeService.create_subscription(user, product, payment_method_id, stripe_promo_code_id)

    subscription = Subscription.new(user: user, product: product)
                               .assign_stripe_attrs(stripe_subscription)

    subscription.save!

    context.subscription = subscription
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
