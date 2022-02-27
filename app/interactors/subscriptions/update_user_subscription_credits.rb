module Subscriptions
  class UpdateUserSubscriptionCredits
    include Interactor

    def call
      user = context.user
      new_product = context.product
      old_product = context.old_product
      active_subscription = user.active_subscription
      new_product_credits = new_product.credits

      credits =
        if !active_subscription || new_product.unlimited? || old_product.unlimited?
          new_product_credits
        else
          used_credits = old_product.credits - user.subscription_credits
          new_credits = new_product_credits - used_credits
          new_credits.negative? ? 0 : new_credits
        end

      user.subscription_credits = credits
      user.save!
    end
  end
end
