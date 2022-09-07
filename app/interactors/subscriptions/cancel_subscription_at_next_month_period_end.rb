module Subscriptions
  class CancelSubscriptionAtNextMonthPeriodEnd
    include Interactor

    def call
      subscription = context.subscription
      user = subscription.user

      raise SubscriptionIsNotActiveException if subscription.no_longer_active?

      subscription.update!(mark_cancel_at_period_end_at: subscription.current_period_end + 2.days)

      SlackService.new(user).subscription_scheduled_cancellation(subscription)
    end
  end
end
