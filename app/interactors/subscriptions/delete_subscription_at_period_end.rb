module Subscriptions
  class DeleteSubscriptionAtPeriodEnd
    include Interactor

    def call
      subscription = context.subscription

      raise SubscriptionIsNotActiveException if subscription.no_longer_active?

      stripe_subscription = StripeService.cancel_subscription_at_period_end(subscription)

      subscription = subscription.assign_stripe_attrs(stripe_subscription)
      subscription.mark_cancel_at_period_end_at = nil

      subscription.save!
    end
  end
end
