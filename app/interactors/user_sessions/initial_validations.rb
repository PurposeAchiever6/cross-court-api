module UserSessions
  class InitialValidations
    include Interactor

    def call
      user = context.user
      date = context.date
      session = context.session
      user_active_subscription = user.active_subscription

      raise UserFlaggedException if user.flagged?
      raise FullSessionException if session.full?(date, user)
      raise SubscriptionIsNotActiveException if user_active_subscription&.paused?
      raise SessionAllowedMembersException unless session.allowed_for_member?(user)
    end
  end
end
