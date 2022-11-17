class SessionOnlyForMembersException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.only_for_members')

    super(message)
  end
end
