class FullSessionException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.full')

    super(message)
  end
end
