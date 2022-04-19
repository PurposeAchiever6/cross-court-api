module Subscriptions
  class CreateFeedback
    include Interactor

    def call
      user = context.user
      subscription_feedback = SubscriptionFeedback.create!(user: user, feedback: feedback)
      SlackService.new(user).subscription_feedback(subscription_feedback)
      SubscriptionMailer.with(
        user_id: user.id,
        feedback: feedback
      ).feedback.deliver_later

      context.subscription_feedback = subscription_feedback
    end

    private

    def feedback
      experience_rate = context.experiencie_rate
      service_rate = context.service_rate
      recommend_rate = context.recommend_rate
      feedback = context.feedback

      "Overall Experience: #{experience_rate}.\n" \
      "Service as Described: #{service_rate}.\n" \
      "Join Again or Recommend: #{recommend_rate}.\n" \
      "\n" \
      "Feedback: #{feedback}"
    end
  end
end
