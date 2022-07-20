module Subscriptions
  class UpdateUserSubscriptionCredits
    include Interactor

    def call
      user = context.user
      product = context.product

      user.subscription_credits = product.credits

      user.save!
    end
  end
end
