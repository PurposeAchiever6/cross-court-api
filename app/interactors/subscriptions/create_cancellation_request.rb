module Subscriptions
  class CreateCancellationRequest
    include Interactor

    def call
      user = context.user

      subscription_cancellation_request = SubscriptionCancellationRequest.create!(
        user: user,
        reason: reason
      )

      SlackService.new(user).subscription_cancellation_request(subscription_cancellation_request)
      SubscriptionMailer.with(
        user_id: user.id,
        reason: reason
      ).cancellation_request.deliver_later

      context.subscription_cancellation_request = subscription_cancellation_request
    end

    private

    def reason
      experience_rate = context.experiencie_rate
      service_rate = context.service_rate
      recommend_rate = context.recommend_rate
      reason = context.reason

      "Overall Experience: #{experience_rate}.\n" \
      "Service as Described: #{service_rate}.\n" \
      "Join Again or Recommend: #{recommend_rate}.\n" \
      "\n" \
      "Reason: #{reason}"
    end
  end
end
