module UserSessions
  class ReserveTeamJob < ApplicationJob
    queue_as :default

    def perform
      notify_reserve_team(hours: 10, min_bookings: 0, max_bookings: 5)
      notify_reserve_team(hours: 5, min_bookings: 4, max_bookings: 10)
    end

    def notify_reserve_team(hours:, min_bookings:, max_bookings:)
      user_sessions = SessionReminderQuery.new(UserSession.not_canceled)
                                          .in(hours)

      session_bookings = user_sessions.group(:session_id).count

      session_bookings.each do |session_id, bookings|
        next unless bookings > min_bookings && bookings < max_bookings

        session = Session.find(session_id)
        next if session.is_private || session.coming_soon || session.is_open_club

        location = session.location

        User.reserve_team.find_each do |user|
          SonarService.send_message(
            user,
            I18n.t(
              'notifier.sonar.reserve_team',
              time: session.time.strftime(Session::TIME_FORMAT),
              location: location.name,
              link: "#{ENV['FRONTENT_URL']}/locations"
            )
          )
        end
      end
    end
  end
end
