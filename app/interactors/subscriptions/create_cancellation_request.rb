module Subscriptions
  class CreateCancellationRequest
    include Interactor

    def call
      user = context.user
      reason = context.reason

      subscription_cancellation_request = SubscriptionCancellationRequest.create!(
        user:,
        reason:
      )

      SlackService.new(user).subscription_cancellation_request(subscription_cancellation_request)
      SubscriptionMailer.with(
        user_id: user.id,
        reason:
      ).cancellation_request.deliver_later

      context.subscription_cancellation_request = subscription_cancellation_request
    end
  end
end