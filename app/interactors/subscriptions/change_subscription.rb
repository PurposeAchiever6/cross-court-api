module Subscriptions
  class ChangeSubscription
    include Interactor

    def call
      user = context.user
      subscription = context.subscription
      product = context.product
      payment_method = user.payment_methods.find(context.payment_method_id)
      promo_code = context.promo_code

      stripe_subscription = StripeService.update_subscription(
        subscription,
        product,
        payment_method.stripe_id,
        promo_code
      )

      subscription = subscription.assign_stripe_attrs(stripe_subscription)

      context.old_product = subscription.product
      context.old_promo_code = subscription.promo_code
      subscription.product_id = product.id
      subscription.promo_code_id = promo_code&.id

      subscription.save!

      context.subscription = subscription
    rescue Stripe::StripeError => e
      context.fail!(message: e.message)
    end
  end
end
