module Subscriptions
  class UpdateUserSubscriptionCredits
    include Interactor

    def call
      user = context.user
      product = context.product

      user.subscription_credits = product.credits
      user.subscription_skill_session_credits = product.skill_session_credits

      user.save!
    end
  end
end
