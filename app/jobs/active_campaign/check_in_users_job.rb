module ActiveCampaign
  class CheckInUsersJob < ApplicationJob
    queue_as :default

    def perform(user_session_ids)
      active_campaign_service = ActiveCampaignService.new

      UserSession.where(id: user_session_ids).checked_in.includes(:user).each do |user_session|
        user = user_session.user

        event =
          if user_session.is_free_session
            ::ActiveCampaign::Deal::Event::FREE_SESSION_CHECK_IN
          else
            ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN
          end

        active_campaign_service.create_deal(event, user)

        send_time_to_re_up(user)
        send_drop_in_re_up(user, user_session)
      end
    end

    private

    def active_campaign_service
      @active_campaign_service ||= ActiveCampaignService.new
    end

    def send_time_to_re_up(user)
      return unless user.subscription_credits.zero? && user.active_subscription.present?

      active_campaign_service.create_deal(::ActiveCampaign::Deal::Event::TIME_TO_RE_UP, user)
    end

    def send_drop_in_re_up(user, user_session)
      return unless !user_session.is_free_session &&
                    user.active_subscription.blank? &&
                    user.first_not_free_session?

      active_campaign_service.create_deal(::ActiveCampaign::Deal::Event::DROP_IN_RE_UP, user)
    end
  end
end
