module Sessions
  class Cancel
    include Interactor

    def call
      session = context.session
      date = context.date
      with_open_club = context.with_open_club

      raise PastSessionException if session.past?(date)

      user_sessions = session.not_canceled_reservations(date).includes(:user, session: :location)

      user_sessions.each do |user_session|
        UserSessions::Cancel.call(
          user_session:,
          from_session_canceled: true,
          canceled_with_open_club: with_open_club
        )
      end

      if session.recurring?
        session.session_exceptions.find_or_create_by!(date:)
      else
        session.destroy!
      end

      return unless with_open_club

      Session.create!(
        is_open_club: true,
        location_id: session.location_id,
        start_time: date,
        time: session.time,
        duration_minutes: session.duration_minutes,
        guests_allowed: 10,
        guests_allowed_per_user: 2
      )
    end
  end
end
