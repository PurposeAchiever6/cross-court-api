module Subscriptions
  class FirstMonthSurveyEmailJob < ApplicationJob
    queue_as :default

    def perform(subscription_id)
      subscription = Subscription.find(subscription_id)

      return unless subscription.active?

      user_id = subscription.user.id

      SubscriptionMailer.with(user_id:).first_month_survey.deliver_now
    end
  end
end
