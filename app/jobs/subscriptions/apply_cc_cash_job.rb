module Subscriptions
  class ApplyCcCashJob < ApplicationJob
    queue_as :default

    def perform(user_id, subscription_id)
      user = User.find(user_id)
      subscription = Subscription.find(subscription_id)

      Subscriptions::ApplyCcCash.call(user:, subscription:)
    end
  end
end
