class UserSessionsQuery
  attr_reader :relation

  def initialize(relation = UserSession.all)
    @relation = relation.joins(session: :location)
  end

  def finished_cancellation_time
    relation.where('date = (current_timestamp at time zone locations.time_zone)::date AND
    to_char((current_timestamp at time zone locations.time_zone) +
    interval :cancellation_period hour, :time_format) >
    to_char(time, :time_format)', cancellation_period: ENV['CANCELLATION_PERIOD'],
                                  time_format: Session::QUERY_TIME_FORMAT)
  end
end
