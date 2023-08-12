module Sessions
  class CheckInUsersJob < ApplicationJob
    queue_as :default

    def perform(user_session_ids, checked_in_at:)
      UserSession.where(id: user_session_ids)
                 .checked_in
                 .includes(:session, user: :active_subscription)
                 .each do |user_session|
        user = user_session.user
        session = user_session.session
        cc_cash_earned = session.cc_cash_earned

        user.increment!(:cc_cash, cc_cash_earned) if cc_cash_earned.positive?

        UserSessions::LateArrival.call(
          user_session:,
          checked_in_time: Time.zone.at(checked_in_at)
        )

        has_active_subscription = user.active_subscription.present?
        event = ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN

        if user_session.first_session
          event = ::ActiveCampaign::Deal::Event::FIRST_SESSION_CHECK_IN
          enqueue_no_purchase_placed_job(user) unless has_active_subscription
        end

        begin
          active_campaign_service.create_deal(event, user)

          send_drop_in_re_up(user, user_session)
          send_checked_in_session_notice(user) if has_active_subscription
        rescue ActiveCampaignException => e
          Rollbar.error(e)
        end
      end
    end

    private

    def active_campaign_service
      @active_campaign_service ||= ActiveCampaignService.new
    end

    def enqueue_no_purchase_placed_job(user)
      ::ActiveCampaign::NoPurchasePlacedAfterCheckInJob.set(wait: 24.hours)
                                                       .perform_later(user.id)
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
