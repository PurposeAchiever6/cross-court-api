module UserSessions
  class ValidateBackToBack
    include Interactor

    def call
      user = context.user
      session = context.session
      user_session = context.user_session
      date = user_session.date

      if session.allow_back_to_back_reservations || user_session.in_back_to_back_allowed_time?
        return
      end

      session.back_to_back_sessions(date).each do |back_to_back_session|
        not_allowed_back_to_back = !back_to_back_session.allow_back_to_back_reservations
        user_reserved_back_to_back = user.not_canceled_user_session?(back_to_back_session, date)

        if not_allowed_back_to_back && user_reserved_back_to_back
          raise BackToBackSessionReservationException
        end
      end
    end
  end
end
