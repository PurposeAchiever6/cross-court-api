class SessionGuestsException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.session_guests.generic_error')

    super(message)
  end
end
