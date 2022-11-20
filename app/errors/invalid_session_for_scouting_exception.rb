class InvalidSessionForScoutingException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.user_sessions.invalid_session_for_scouting')

    super(message)
  end
end
