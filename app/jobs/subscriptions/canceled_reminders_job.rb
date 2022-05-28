module Subscriptions
  class CanceledRemindersJob < ApplicationJob
    queue_as :default

    def perform
      Subscription.active
                  .cancel_at_period_end
                  .period_end_on_date(Time.zone.tomorrow)
                  .includes(:user, :product)
                  .find_each do |subscription|
        user = subscription.user
        product = subscription.product

        SonarService.send_message(
          user,
          I18n.t('notifier.sonar.canceled_subscription_reminder',
                 name: user.first_name,
                 product_name: product.name,
                 subscriptions_url: "#{ENV['FRONTENT_URL']}/memberships")
        )
      end
    end
  end
end
