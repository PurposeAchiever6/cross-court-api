class UserSessionsQuery
  attr_reader :relation

  def initialize(relation = UserSession.all)
    @relation = relation.joins(session: :location)
  end

  def finished_cancellation_time
    relation.where('date = (current_timestamp at time zone locations.time_zone)::date AND
    to_char((current_timestamp at time zone locations.time_zone) +
    interval :cancellation_period hour, :time_format) >
    to_char(time, :time_format)', cancellation_period: ENV.fetch('CANCELLATION_PERIOD', nil),
                                  time_format: Session::QUERY_TIME_FORMAT)
  end

  def first_sessions_last_hour_checked_in
    relation.first_sessions
            .checked_in
            .where('date = (current_timestamp at time zone locations.time_zone)::date')
            .where('to_char((current_timestamp at time zone locations.time_zone) -
                    interval \'2\' hour, :time_format) <=
                    to_char(time, :time_format)', time_format: Session::QUERY_TIME_FORMAT)
            .where('to_char((current_timestamp at time zone locations.time_zone) -
                    interval \'1\' hour, :time_format) >
                    to_char(time, :time_format)', time_format: Session::QUERY_TIME_FORMAT)
  end
end
