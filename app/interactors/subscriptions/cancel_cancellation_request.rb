module Subscriptions
  class CancelCancellationRequest
    include Interactor

    def call
      user = context.user
      subscription = user.active_subscription

      SubscriptionCancellationRequest.pending
                                     .for_user(user)
                                     .each(&:cancel_by_user!)

      context.subscription = subscription
    end
  end
end
