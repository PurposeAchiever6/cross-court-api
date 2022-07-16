class ReserveTeamNotAllowedException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.reserve_team_not_allowed')

    super(message)
  end
end
