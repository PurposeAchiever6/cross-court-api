class SessionAllowedMembersException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.not_allowed_for_member')

    super(message)
  end
end
