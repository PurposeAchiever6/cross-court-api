module Subscriptions
  class ChangeSubscription
    include Interactor

    def call
      user = context.user
      subscription = context.subscription
      product = context.product
      payment_method = context.payment_method
      promo_code = context.promo_code

      proration_date = $redis.get("#{user.id}-#{subscription.id}-proration_date")

      old_product = subscription.product
      old_promo_code = subscription.promo_code

      raise SubscriptionHasSameProductException if old_product == product

      stripe_subscription = StripeService.update_subscription(
        subscription,
        product,
        payment_method.stripe_id,
        promo_code,
        proration_date
      )

      subscription = subscription.assign_stripe_attrs(stripe_subscription)

      subscription.payment_method_id = payment_method.id
      subscription.product_id = product.id
      subscription.promo_code_id = promo_code&.id
      subscription.mark_cancel_at_period_end_at = nil

      subscription.save!

      context.old_product = old_product
      context.old_promo_code = old_promo_code
      context.subscription = subscription
    end
  end
end
