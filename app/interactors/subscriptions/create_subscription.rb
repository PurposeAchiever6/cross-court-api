module Subscriptions
  class CreateSubscription
    include Interactor

    def call
      user = context.user
      product = context.product
      payment_method = context.payment_method
      promo_code = context.promo_code

      if user.active_subscription
        context.fail!(message: I18n.t('api.errors.subscriptions.user_has_active'))
      end

      if promo_code&.invalid?(user, product)
        context.fail!(message: I18n.t('api.errors.promo_code.invalid'))
      end

      stripe_subscription = StripeService.create_subscription(
        user,
        product,
        payment_method.stripe_id,
        promo_code
      )

      if stripe_subscription.status.to_sym == :incomplete
        context.fail!(message: I18n.t('api.errors.subscriptions.incomplete_status'))
      end

      subscription = Subscription.new(
        user: user,
        product: product,
        promo_code: promo_code,
        payment_method: payment_method
      ).assign_stripe_attrs(stripe_subscription)

      subscription.save!

      context.subscription = subscription
    rescue Stripe::StripeError => e
      context.fail!(message: e.message)
    end
  end
end
