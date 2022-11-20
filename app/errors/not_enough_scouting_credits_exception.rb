class NotEnoughScoutingCreditsException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.user_sessions.not_enough_scouting_credits')

    super(message)
  end
end
