module Users
  class InactiveNonMembersJob < ApplicationJob
    queue_as :default

    def perform
      active_campaign_service = ActiveCampaignService.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      )

      User.includes(
        :last_checked_in_user_session,
        :first_future_user_session,
        :active_subscription
      ).no_credits.find_each do |user|
        last_session = user.last_checked_in_user_session

        next unless last_session
        next if user.first_future_user_session
        next if user.active_subscription

        today_date = Time.now.in_time_zone(last_session.time_zone).to_date
        last_session_was_first_session = last_session.first_session

        case last_session.date
        when today_date - 1.day
          if last_session_was_first_session
            SlackService.new(user).inactive_first_timer_user(last_session_days_ago: 1)
          end
        when today_date - 14.days
          if last_session_was_first_session
            SlackService.new(user).inactive_first_timer_user(last_session_days_ago: 14)
            active_campaign_service.create_deal(
              ::ActiveCampaign::Deal::Event::FREE_LOADERS,
              user,
              user_session_id: last_session.id
            )
          end
        when today_date - 1.month
          SlackService.new(user).inactive_user
        end
      rescue ActiveCampaignException
        next
      end
    end
  end
end
