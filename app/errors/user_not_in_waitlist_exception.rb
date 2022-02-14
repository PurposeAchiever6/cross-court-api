class UserNotInWaitlistException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.waitlists.user_not_in_waitlist')

    super(message)
  end
end
