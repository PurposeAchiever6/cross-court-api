module UserSessions
  class OpenClubValidations
    include Interactor

    def call
      user = context.user
      active_subscription = user.active_subscription

      if !active_subscription || active_subscription&.paused?
        raise SubscriptionException, I18n.t('api.errors.users.not_member')
      end
    end
  end
end
