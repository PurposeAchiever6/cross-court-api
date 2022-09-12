class UserUpdateRequestIsNotPendingException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.user_update_requests.not_pending')

    super(message)
  end
end
