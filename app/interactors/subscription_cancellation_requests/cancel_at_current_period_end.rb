module SubscriptionCancellationRequests
  class CancelAtCurrentPeriodEnd
    include Interactor

    def call
      subscription_cancellation_request = context.subscription_cancellation_request

      unless subscription_cancellation_request.pending?
        raise SubscriptionCancellationRequestIsNotPendingException
      end

      user = subscription_cancellation_request.user

      Subscriptions::CancelSubscriptionAtPeriodEnd.call(
        user:,
        subscription: user.active_subscription
      )

      subscription_cancellation_request.cancel_at_current_period_end!
    end
  end
end
