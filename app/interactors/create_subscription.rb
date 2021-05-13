class CreateSubscription
  include Interactor

  def call
    user = context.user
    product = context.product
    payment_method_id = context.payment_method

    context.fail!(message: I18n.t('api.errors.subscriptions.user_has_active')) if user.active_subscription

    stripe_subscription = StripeService.create_subscription(user, product, payment_method_id)

    Subscription.new(user: user, product: product)
                .assign_stripe_attrs(stripe_subscription)
                .save!
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
