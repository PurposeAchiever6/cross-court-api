module Sessions
  class CheckInUsersJob < ApplicationJob
    queue_as :default

    def perform(user_session_ids, checked_in_at:)
      active_campaign_service = ActiveCampaignService.new

      UserSession.where(id: user_session_ids)
                 .checked_in
                 .includes(user: :active_subscription)
                 .each do |user_session|
        user = user_session.user
        session = user_session.session
        cc_cash_earned = session.cc_cash_earned

        user.increment!(:cc_cash, cc_cash_earned) if cc_cash_earned.positive?

        UserSessions::LateArrival.call(
          user_session:,
          checked_in_time: Time.zone.at(checked_in_at)
        )

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
      checked_in_sessions = user.user_sessions.checked_in.count

      return unless number_of_sessions_to_notify.include?(checked_in_sessions)

      SessionMailer.with(user_id: user.id, number_of_sessions: checked_in_sessions)
                   .checked_in_session_notice
                   .deliver_later
    end

    def number_of_sessions_to_notify
      @number_of_sessions_to_notify ||= ENV.fetch('NUMBER_OF_SESSIONS_TO_NOTIFY', '')
                                           .split(',').map(&:to_i)
    end
  end
end
