module Subscriptions
  class RenewUserSubscriptionCredits
    include Interactor

    def call
      user = context.user
      subscription = context.subscription

      user.subscription_credits = subscription.credits

      user.save!
    end
  end
end
