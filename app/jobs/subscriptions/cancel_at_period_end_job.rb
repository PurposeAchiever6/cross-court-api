module Subscriptions
  class CancelAtPeriodEndJob < ApplicationJob
    queue_as :default

    def perform
      Subscription.where(mark_cancel_at_period_end_at: Time.zone.today)
                  .not_cancel_at_period_end
                  .includes(:user)
                  .find_each do |subscription|
        next if subscription.no_longer_active?

        Subscriptions::CancelSubscriptionAtPeriodEnd.call(
          user: subscription.user,
          subscription:
        )
      end
    end
  end
end
