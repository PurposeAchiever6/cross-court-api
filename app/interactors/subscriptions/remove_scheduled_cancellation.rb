module Subscriptions
  class RemoveScheduledCancellation
    include Interactor

    def call
      subscription = context.subscription
      user = subscription.user

      subscription.update!(mark_cancel_at_period_end_at: nil)

      SlackService.new(user).subscription_scheduled_cancellation_removed(subscription)
    end
  end
end
