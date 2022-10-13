module UserSessions
  class InitialValidations
    include Interactor

    def call
      user = context.user
      date = context.date
      session = context.session

      raise UserFlaggedException if user.flagged?
      raise FullSessionException if session.full?(date, user)
      raise SubscriptionIsNotActiveException if user.active_subscription&.paused?
    end
  end
end
