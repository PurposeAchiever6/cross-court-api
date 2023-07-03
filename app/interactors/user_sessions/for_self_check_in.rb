module UserSessions
  class ForSelfCheckIn
    include Interactor

    def call
      location = Location.find_by(id: context.location_id)

      unless location
        context.user_sessions = []
        return
      end

      user = context.user
      now = Time.zone.local_to_utc(Time.current.in_time_zone(location.time_zone))

      context.user_sessions = user.user_sessions
                                  .future
                                  .not_checked_in
                                  .reserved_or_confirmed
                                  .by_date(now.to_date)
                                  .includes(
                                    :session_survey,
                                    session: %i[skill_level location]
                                  )
                                  .where(sessions: { location_id: location.id })
                                  .where(
                                    'sessions.time >= ? AND sessions.time <= ?',
                                    now,
                                    now + 2.hours
                                  )
                                  .order('sessions.time')
    end
  end
end
