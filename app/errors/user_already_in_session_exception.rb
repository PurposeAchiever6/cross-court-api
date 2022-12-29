class UserAlreadyInSessionException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.user_already_in')

    super(message)
  end
end
