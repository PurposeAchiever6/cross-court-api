class UltimatumReadyQuery
  QUERY_TIME_FORMAT = 'HH24'.freeze
  attr_reader :relation

  def initialize(relation = UserSession.all)
    @relation = relation.reserved.joins(session: :location)
  end

  def confirmation_pending
    relation.where("date = (current_timestamp at time zone locations.time_zone)::date
                   AND to_char(current_timestamp at time zone locations.time_zone +
                   interval :cancellation_period hour, :time_format) = to_char(time, :time_format)",
                   time_format: QUERY_TIME_FORMAT,
                   cancellation_period: ENV['CANCELLATION_PERIOD'])
  end
end
