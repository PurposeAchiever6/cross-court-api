module SubscriptionCancellationRequests
  class Ignore
    include Interactor

    def call
      subscription_cancellation_request = context.subscription_cancellation_request

      unless subscription_cancellation_request.pending?
        raise SubscriptionCancellationRequestIsNotPendingException
      end

      subscription_cancellation_request.ignored!
    end
  end
end
