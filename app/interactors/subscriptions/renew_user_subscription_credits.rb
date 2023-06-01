module Subscriptions
  class RenewUserSubscriptionCredits
    include Interactor

    def call
      user = context.user
      subscription = context.subscription
      product = subscription.product

      return unless subscription.active?

      subscription_credits = subscription.credits

      if product.unlimited?
        user.subscription_credits = subscription_credits
      else
        max_rollover_credits = product.max_rollover_credits
        rollover_credits = user.unlimited_credits? ? 0 : user.subscription_credits

        if max_rollover_credits && rollover_credits > max_rollover_credits
          rollover_credits = max_rollover_credits
        end

        user.subscription_credits = subscription_credits + rollover_credits
      end

      user.subscription_skill_session_credits = subscription.skill_session_credits

      user.save!
    end
  end
end
