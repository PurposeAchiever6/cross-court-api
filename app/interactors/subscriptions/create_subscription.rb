module Subscriptions
  class CreateSubscription
    include Interactor

    def call
      user = context.user
      product = context.product
      payment_method = context.payment_method
      promo_code = context.promo_code

      reserve_team_validation(product, user)

      if user.active_subscription
        context.fail!(message: I18n.t('api.errors.subscriptions.user_has_active'))
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
        user:,
        product:,
        promo_code:,
        payment_method:
      ).assign_stripe_attrs(stripe_subscription)

      subscription.save!

      payment_intent_id = StripeService.retrieve_invoice(
        stripe_subscription.latest_invoice
      ).payment_intent

      context.payment_intent_id = payment_intent_id
      context.subscription = subscription
    rescue Stripe::StripeError => e
      context.fail!(message: e.message)
    end

    def reserve_team_validation(product, user)
      reserve_team_product = product.reserve_team?
      reserve_team_user = user.reserve_team?

      if (reserve_team_product && !reserve_team_user) ||
         (!reserve_team_product && reserve_team_user)
        raise ReserveTeamMismatchException
      end
    end
  end
end
