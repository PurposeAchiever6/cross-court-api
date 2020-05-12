class UserSessionReminderQuery
  QUERY_TIME_FORMAT = 'HH24'.freeze
  attr_reader :relation

  def initialize(relation = UserSession.all)
    @relation = relation.reserved.joins(:user, session: :location)
  end

  def for_today
    relation.where('date = (current_timestamp at time zone locations.time_zone)::date')
  end

  def in_24_hours
    relation.where(
      "date = (current_timestamp at time zone locations.time_zone)::date + integer '1'
       AND to_char(current_timestamp at time zone locations.time_zone, :time_format) =
       to_char(time, :time_format)",
      time_format: QUERY_TIME_FORMAT
    )
  end

  def in(hours)
    for_today.where(
      "to_char(current_timestamp at time zone locations.time_zone, :time_format) =
       to_char(time - interval ':hours hour', :time_format)",
      hours: hours, time_format: QUERY_TIME_FORMAT
    )
  end
end
