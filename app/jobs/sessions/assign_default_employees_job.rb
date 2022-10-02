module Sessions
  class AssignDefaultEmployeesJob < ApplicationJob
    queue_as :default

    def perform
      from_date = (Time.zone.today + 1.week).beginning_of_week
      to_date = from_date.end_of_week

      Location.find_each do |location|
        sessions = Session.includes(:session_exceptions)
                          .by_location(location.id)
                          .for_range(from_date, to_date)
                          .flat_map do |session_event|
                            session_event.calendar_events(from_date, to_date)
                          end

        sessions.each { |session| create_employee_session(session) }
      end
    end

    private

    def create_employee_session(session)
      default_referee_id = session.default_referee_id
      default_sem_id = session.default_sem_id
      default_coach_id = session.default_coach_id

      return unless default_referee_id || default_sem_id || default_coach_id

      session_id = session.id
      date = session.start_time

      referee_session = RefereeSession.find_by(session_id: session_id, date: date)
      if default_referee_id && !referee_session
        RefereeSession.find_or_create_by!(
          user_id: default_referee_id,
          session_id: session_id,
          date: date
        )
      end

      sem_session = SemSession.find_by(session_id: session_id, date: date)
      if default_sem_id && !sem_session
        SemSession.find_or_create_by!(
          user_id: default_sem_id,
          session_id: session_id,
          date: date
        )
      end

      coach_session = CoachSession.find_by(session_id: session_id, date: date)
      if default_coach_id && !coach_session
        CoachSession.find_or_create_by!(
          user_id: default_coach_id,
          session_id: session_id,
          date: date
        )
      end
    end
  end
end
