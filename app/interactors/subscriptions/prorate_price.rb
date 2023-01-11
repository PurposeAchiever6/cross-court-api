module Subscriptions
  class ProratePrice
    include Interactor

    def call
      user = context.user
      new_product = context.new_product
      promo_code = context.promo_code

      current_subscription = user.active_subscription

      items = [{
        id: current_subscription.stripe_item_id,
        price: new_product.stripe_price_id
      }]

      proration_date = Time.now.to_i
      $redis.setex("#{user.id}-#{current_subscription.id}-proration_date", 1800, proration_date)

      context.invoice = StripeService.upcoming_invoice(
        user.stripe_id,
        current_subscription.stripe_id,
        items,
        proration_date,
        promo_code
      )
    end
  end
end
