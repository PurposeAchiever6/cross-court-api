class SessionInvalidDateException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.invalid_date')

    super(message)
  end
end
