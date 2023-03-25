module UserSessions
  class ValidateBackToBack
    include Interactor

    def call
      user = context.user
      session = context.session
      user_session = context.user_session
      date = user_session.date

      raise BackToBackSessionReservationException if session.back_to_back_restricted?(date, user)
    end
  end
end
