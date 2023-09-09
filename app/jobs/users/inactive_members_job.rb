module Users
  class InactiveMembersJob < ApplicationJob
    queue_as :default

    def perform
      User.includes(
        :first_future_user_session,
        :last_checked_in_user_session,
        active_subscription: :product
      ).members.find_each do |user|
        send_credits_left_reminder = send_credits_left_reminder?(user)
        product = user.active_subscription.product

        if send_credits_left_reminder
          SlackService.new(user).member_with_credits_left(
            subscription_name: product.name,
            credits_used: product.credits - user.subscription_credits
          )
          create_risk_member_deal(user)
        end

        next if user.first_future_user_session
        next unless user.last_checked_in_user_session

        if send_credits_left_reminder
          SonarService.send_message(
            user,
            I18n.t('notifier.sonar.subscription_credits_left_reminder',
                   name: user.first_name,
                   credits_left: user.subscription_credits,
                   end_date: user.active_subscription.current_period_end.strftime('%e of %B'),
                   schedule_url: "#{ENV.fetch('FRONTENT_URL', nil)}/locations")
          )
        elsif send_book_reminder?(user)
          SonarService.send_message(user, I18n.t('notifier.sonar.active_subscription_book_reminder',
                                                 name: user.first_name,
                                                 schedule_url: "#{ENV.fetch('FRONTENT_URL',
                                                                            nil)}/locations"))
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
      1.week.ago.to_date == user.last_checked_in_user_session.date && user.credits?
    end

    def create_risk_member_deal(user)
      ActiveCampaignService.new(
        pipeline_name: ActiveCampaign::Deal::Pipeline::EMAILS
      ).create_deal(
        ActiveCampaign::Deal::Event::AT_RISK_MEMBERS,
        user
      )
    rescue ActiveCampaignException => e
      Rollbar.error(e)
    end
  end
end
