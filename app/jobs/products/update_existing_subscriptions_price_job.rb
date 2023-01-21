module Products
  class UpdateExistingSubscriptionsPriceJob < ApplicationJob
    queue_as :default

    def perform(product_id)
      product = Product.find(product_id)

      Subscription.active_or_paused.for_product(product).find_each do |subscription|
        stripe_subscription = StripeService.update_subscription_price(
          subscription,
          product.stripe_price_id
        )

        subscription.assign_stripe_attrs(stripe_subscription).save!
      rescue StandardError => e
        Rollbar.error(e, product_id: product.id, subscription_id: subscription.id)
      end
    end
  end
end
