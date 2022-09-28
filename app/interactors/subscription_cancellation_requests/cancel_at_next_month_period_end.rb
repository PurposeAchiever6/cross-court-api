module SubscriptionCancellationRequests
  class CancelAtNextMonthPeriodEnd
    include Interactor

    def call
      subscription_cancellation_request = context.subscription_cancellation_request

      unless subscription_cancellation_request.pending?
        raise SubscriptionCancellationRequestIsNotPendingException
      end

      Subscriptions::CancelSubscriptionAtNextMonthPeriodEnd.call(
        subscription: subscription_cancellation_request.user.active_subscription
      )

      subscription_cancellation_request.cancel_at_next_month_period_end!
    end
  end
end
