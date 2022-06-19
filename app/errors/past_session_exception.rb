class PastSessionException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.has_already_been_played')

    super(message)
  end
end
