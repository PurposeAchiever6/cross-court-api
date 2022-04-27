module Subscriptions
  class UnpauseSubscription
    include Interactor

    def call
      subscription = context.subscription

      raise SubscriptionIsNotPausedException unless subscription.paused?

      stripe_subscription = StripeService.unpause_subscription(subscription)
      subscription.assign_stripe_attrs(stripe_subscription).save!

      subscription.subscription_pauses.last.update!(
        unpaused: true,
        unpaused_at: Time.current
      )
    end
  end
end
