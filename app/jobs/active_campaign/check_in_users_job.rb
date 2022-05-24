module ActiveCampaign
  class CheckInUsersJob < ApplicationJob
    queue_as :default

    def perform(user_session_ids)
      active_campaign_service = ActiveCampaignService.new

      UserSession.where(id: user_session_ids)
                 .checked_in
                 .includes(user: :active_subscription)
                 .each do |user_session|
        user = user_session.user

        event = if user_session.first_session
                  ::ActiveCampaign::Deal::Event::FIRST_SESSION_CHECK_IN
                else
                  ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN
                end

        active_campaign_service.create_deal(event, user)

        send_time_to_re_up(user)
        send_drop_in_re_up(user, user_session)
        send_checked_in_session_notice(user) if user.active_subscription
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
      return unless !user_session.first_session &&
                    !user.active_subscription &&
                    user.first_not_first_session?

      active_campaign_service.create_deal(::ActiveCampaign::Deal::Event::DROP_IN_RE_UP, user)
    end

    def send_checked_in_session_notice(user)
      number_of_sessions = 10
      checked_in_sessions = user.user_sessions.checked_in.count

      return unless checked_in_sessions == number_of_sessions

      SessionMailer.with(user_id: user.id, number_of_sessions: number_of_sessions)
                   .checked_in_session_notice
                   .deliver_later
    end
  end
end
