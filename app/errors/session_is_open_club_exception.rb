class SessionIsOpenClubException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.is_open_club')

    super(message)
  end
end
