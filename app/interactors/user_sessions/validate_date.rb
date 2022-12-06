module UserSessions
  class ValidateDate
    include Interactor

    def call
      user_session = context.user_session
      date = user_session.date
      time_zone = user_session.time_zone
      session = user_session.session

      if session.calendar_events(date, date).empty? ||
         Time.current.in_time_zone(time_zone).to_date > date
        raise InvalidDateException, I18n.t('api.errors.user_sessions.invalid_date')
      end
    end
  end
end
