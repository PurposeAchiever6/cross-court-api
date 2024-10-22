module Subscriptions
  class ResetUserSubscriptionCredits
    include Interactor

    def call
      user = context.user
      user.subscription_credits = 0
      user.subscription_skill_session_credits = 0
      user.save!
    end
  end
end
