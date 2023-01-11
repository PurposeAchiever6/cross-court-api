module Sessions
  class Vote
    include Interactor

    def call
      session = context.session
      user = context.user
      date = context.date

      raise SessionInvalidDateException if session.invalid_date?(date)
      raise SessionNotComingSoonException unless session.coming_soon

      UserSessionVote.create!(session:, user:, date:)
    end
  end
end
