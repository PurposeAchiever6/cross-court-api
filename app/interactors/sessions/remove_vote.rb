module Sessions
  class RemoveVote
    include Interactor

    def call
      session = context.session
      user = context.user
      date = context.date

      user_session_vote = session.user_session_votes.by_date(date).find_by(user: user)

      raise UserDidNotVoteSessionException unless user_session_vote

      user_session_vote.destroy!
    end
  end
end
