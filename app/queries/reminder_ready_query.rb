class ReminderReadyQuery
  QUERY_TIME_FORMAT = 'HH24'.freeze
  attr_reader :relation

  def initialize(relation = UserSession.all)
    @relation = relation.reserved.joins(:user, session: :location)
  end

  def tomorrow_user_sessions
    relation.where("date = (current_timestamp at time zone locations.time_zone)::date + integer '1'
                   AND to_char(current_timestamp at time zone locations.time_zone, :date_format) =
                   to_char(time, :date_format)", date_format: QUERY_TIME_FORMAT)
  end

  def email_pending
    tomorrow_user_sessions.email_not_sent
  end

  def sms_pending
    tomorrow_user_sessions.sms_not_sent
  end
end
