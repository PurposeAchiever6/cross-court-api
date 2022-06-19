module Sessions
  class Cancel
    include Interactor

    def call
      session = context.session
      date = context.date

      raise PastSessionException if session.past?(date)

      user_sessions = session.not_canceled_reservations(date).includes(:user, session: :location)

      user_sessions.each do |user_session|
        UserSessions::Cancel.call(
          user_session: user_session,
          from_session_canceled: true
        )
      end

      if session.recurring?
        session.session_exceptions.find_or_create_by!(date: date)
      else
        session.destroy!
      end
    end
  end
end
