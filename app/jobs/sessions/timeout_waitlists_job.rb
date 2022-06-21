module Sessions
  class TimeoutWaitlistsJob < ApplicationJob
    queue_as :default

    def perform
      waitlist_minutes_tolerance = UserSessionWaitlist::MINUTES_TOLERANCE.to_i / 60

      Location.find_each do |location|
        date = Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone)).to_date
        sessions = location.sessions
                           .for_range(date, date)
                           .in_next_minutes(waitlist_minutes_tolerance)
                           .flat_map { |session| session.calendar_events(date, date) }

        sessions.each do |session|
          session.waitlist(date).pending.includes(:user).each do |user_session_waitlist|
            user = user_session_waitlist.user
            SonarService.send_message(
              user,
              I18n.t('notifier.sonar.session_waitlist_timeout',
                     name: user.first_name,
                     time: session.time.strftime(Session::TIME_FORMAT),
                     location: location.name,
                     schedule_url: "#{ENV['FRONTENT_URL']}/locations")
            )

            user_session_waitlist.update!(state: :timeout)
          end
        end
      end
    end
  end
end
