module SubscriptionCancellationRequests
  class CancelImmediately
    include Interactor

    def call
      subscription_cancellation_request = context.subscription_cancellation_request

      unless subscription_cancellation_request.pending?
        raise SubscriptionCancellationRequestIsNotPendingException
      end

      user = subscription_cancellation_request.user

      Subscriptions::CancelSubscription.call(
        user:,
        subscription: user.active_subscription
      )

      subscription_cancellation_request.cancel_immediately!
    end
  end
end
