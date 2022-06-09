class SessionNotComingSoonException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.not_coming_soon')

    super(message)
  end
end
