module Subscriptions
  class FirstMonthSurveyEmailJob < ApplicationJob
    queue_as :default

    def perform(subscription_id)
      subscription = Subscription.find(subscription_id)
      user = subscription.user

      return unless subscription.active? && user.first_subscription?

      SubscriptionMailer.with(user_id: user.id).first_month_survey.deliver_now
    end
  end
end
