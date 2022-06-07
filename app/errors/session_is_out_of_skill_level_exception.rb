class SessionIsOutOfSkillLevelException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.is_out_of_skill_level')

    super(message)
  end
end
