class ReserveTeamMismatchException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.reserve_team_mismatch_exception')

    super(message)
  end
end
