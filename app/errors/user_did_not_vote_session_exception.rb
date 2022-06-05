class UserDidNotVoteSessionException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.votes.user_did_not_vote')

    super(message)
  end
end
