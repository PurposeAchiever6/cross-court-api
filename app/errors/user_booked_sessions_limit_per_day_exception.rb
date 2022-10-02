class UserBookedSessionsLimitPerDayException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.users.booked_sessions_limit_per_day')

    super(message)
  end
end
