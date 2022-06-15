module Subscriptions
  class UnpauseSubscription
    include Interactor

    def call
      subscription = context.subscription
      user = subscription.user

      raise SubscriptionIsNotPausedException unless subscription.paused?

      stripe_subscription = StripeService.unpause_subscription(subscription)
      subscription.assign_stripe_attrs(stripe_subscription).save!

      subscription.subscription_pauses.finished.last.update!(
        unpaused_at: Time.current
      )

      user.update!(subscription_credits: subscription.credits)

      SlackService.new(user).subscription_unpaused(subscription)
    end
  end
end
