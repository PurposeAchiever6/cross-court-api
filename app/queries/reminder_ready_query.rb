class ReminderReadyQuery
  QUERY_TIME_FORMAT = 'HH24'.freeze

  attr_reader :relation

  def initialize(relation = UserSession.all)
    @relation = relation.reserved.joins(:session, :user)
  end

  def user_sessions
    relation.where(date: Date.tomorrow, sms_reminder_sent: false)
            .where('to_char(time, :date_format) = :current_hour',
                   date_format: QUERY_TIME_FORMAT, current_hour: Time.current.hour.to_s)
  end
end
