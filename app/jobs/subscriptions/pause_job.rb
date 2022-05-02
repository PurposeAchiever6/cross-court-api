module Subscriptions
  class PauseJob < ApplicationJob
    queue_as :default

    def perform(subscription_id, resumes_at, subscription_pause_id)
      subscription = Subscription.find(subscription_id)

      return unless subscription.active?

      stripe_subscription = StripeService.pause_subscription(subscription, resumes_at)

      SubscriptionPause.find(subscription_pause_id).update!(status: :actual)
      subscription.assign_stripe_attrs(stripe_subscription).save!
    end
  end
end
