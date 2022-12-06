module UserSessions
  class ConsumeScoutingCredit
    include Interactor

    def call
      user_session = context.user_session
      not_charge_user_credit = context.not_charge_user_credit

      user = user_session.user
      session = user_session.session

      return unless user_session.scouting

      raise InvalidSessionForScoutingException unless session.normal_session?
      raise NotEnoughScoutingCreditsException unless user.scouting_credits?

      user.decrement!(:scouting_credits) unless not_charge_user_credit
    end
  end
end
