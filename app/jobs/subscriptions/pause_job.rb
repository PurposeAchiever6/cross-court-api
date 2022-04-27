module Subscriptions
  class PauseJob < ApplicationJob
    queue_as :default

    def perform(subscription_id, resumes_at)
      subscription = Subscription.find(subscription_id)

      return unless subscription.active?

      stripe_subscription = StripeService.pause_subscription(subscription, resumes_at)

      subscription.assign_stripe_attrs(stripe_subscription).save!
    end
  end
end
