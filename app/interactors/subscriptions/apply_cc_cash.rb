module Subscriptions
  class ApplyCcCash
    include Interactor

    def call
      user = context.user
      subscription = context.subscription
      product = subscription.product
      product_price = product.price.to_i
      user_cc_cash = user.cc_cash

      unless user.apply_cc_cash_to_subscription && subscription.active? && user_cc_cash.positive?
        return
      end

      subscription_discount = StripeService.retrieve_subscription(subscription.stripe_id).discount
      return if subscription_discount.present? && !subscription.promo_code&.cc_cash?

      discount = [user_cc_cash, product_price].min
      code = "user_id:#{user.id}_subscription_id:#{subscription.id}_" \
             "product_id:#{product.id}_#{Time.current.to_i}"

      promo_code_attrs = {
        type: SpecificAmountDiscount.to_s,
        code:,
        discount:,
        use: 'cc_cash',
        duration: :once,
        max_redemptions_by_user: 1,
        times_used: 1,
        products: [product]
      }

      coupon_id = StripeService.create_coupon(promo_code_attrs, [product]).id

      StripeService.apply_coupon_to_subscription(subscription, coupon_id)

      promo_code = PromoCode.create!(promo_code_attrs.merge(stripe_coupon_id: coupon_id))

      subscription.update!(promo_code:)

      user.update!(cc_cash: user_cc_cash - discount)
    end
  end
end
