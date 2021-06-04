class ChangeSubscription
  include Interactor

  def call
    subscription = context.subscription
    product = context.product
    payment_method_id = context.payment_method

    stripe_subscription = StripeService.update_subscription(subscription, product, payment_method_id)

    subscription = subscription.assign_stripe_attrs(stripe_subscription)
    context.old_product = subscription.product
    subscription.product = product

    subscription.save!

    context.subscription = subscription
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
