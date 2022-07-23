module Subscriptions
  class RenewUserSubscriptionCredits
    include Interactor

    def call
      user = context.user
      subscription = context.subscription

      user.subscription_credits = subscription.credits
      user.subscription_skill_session_credits = subscription.skill_session_credits

      user.save!
    end
  end
end
