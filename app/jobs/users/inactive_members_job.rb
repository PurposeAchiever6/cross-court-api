module Users
  class InactiveMembersJob < ApplicationJob
    queue_as :default

    def perform
      User.includes(
        :first_future_user_session,
        :last_checked_in_user_session,
        active_subscription: :product
      ).members.find_each do |user|
        next if user.first_future_user_session
        next unless user.last_checked_in_user_session

        if send_credits_left_reminder?(user)
          SonarService.send_message(
            user,
            I18n.t('notifier.sonar.subscription_credits_left_reminder',
                   name: user.first_name,
                   credits_left: user.subscription_credits,
                   end_date: user.active_subscription.current_period_end.strftime('%e of %B'),
                   schedule_url: "#{ENV['FRONTENT_URL']}/locations")
          )
        elsif send_book_reminder?(user)
          SonarService.send_message(user, I18n.t('notifier.sonar.active_subscription_book_reminder',
                                                 name: user.first_name,
                                                 schedule_url: "#{ENV['FRONTENT_URL']}/locations"))
        end
      end
    end

    private

    def send_credits_left_reminder?(user)
      active_subscription = user.active_subscription

      !active_subscription.unlimited? \
        && user.subscription_credits >= active_subscription.product.credits / 2 \
          && 2.weeks.from_now.to_date == active_subscription.current_period_end.to_date
    end

    def send_book_reminder?(user)
      1.week.ago.to_date == user.last_checked_in_user_session.date
    end
  end
end
