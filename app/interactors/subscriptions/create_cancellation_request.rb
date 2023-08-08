module Subscriptions
  class CreateCancellationRequest
    include Interactor

    def call
      user = context.user
      reason = context.reason
      subscription = user.active_subscription

      user_id = user.id

      subscription_cancellation_request = SubscriptionCancellationRequest.create!(
        user:,
        reason:
      )

      SlackService.new(user).subscription_cancellation_request(subscription_cancellation_request)
      SubscriptionMailer.with(
        user_id:,
        reason:
      ).cancellation_request.deliver_later

      ::ActiveCampaign::CreateDealJob.perform_later(
        ::ActiveCampaign::Deal::Event::SUBMIT_CANCELLATION_REQUEST,
        user_id,
        {},
        ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      )

      context.subscription_cancellation_request = subscription_cancellation_request
      context.subscription = subscription
    end
  end
end
