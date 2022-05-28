module UserSessions
  class RemindersJob < ApplicationJob
    queue_as :default

    def perform
      cancellation_period_hours = Session::CANCELLATION_PERIOD.to_i / 3600

      SessionReminderQuery.new(UserSession.reserved)
                          .in(cancellation_period_hours + 1)
                          .includes(:user, session: :location)
                          .find_each do |user_session|
        user = user_session.user
        first_session = user_session.first_session

        ActiveCampaignService.new.create_deal(
          ::ActiveCampaign::Deal::Event::SESSION_REMINDER_6_HOURS,
          user,
          user_session_id: user_session.id
        )

        i18n_message_key = if first_session
                             'notifier.sonar.today_reminder_first_timers'
                           else
                             'notifier.sonar.today_reminder'
                           end

        SonarService.send_message(
          user,
          I18n.t(i18n_message_key,
                 name: user.first_name,
                 time: user_session.time.strftime(Session::TIME_FORMAT),
                 location: user_session.location.name,
                 cancellation_period_hours: cancellation_period_hours,
                 frontend_url: ENV['FRONTENT_URL'],
                 invite_friend: invite_friend(user_session, user))
        )

        user_session.update!(reminder_sent_at: Time.zone.now)
      end
    end

    private

    def invite_friend(user_session, user)
      return '' if user_session.session.full?(user_session.date, user)

      I18n.t('notifier.sonar.invite_friend', link: user_session.invite_link)
    end
  end
end
