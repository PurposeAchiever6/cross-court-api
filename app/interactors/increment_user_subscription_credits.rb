class IncrementUserSubscriptionCredits
  include Interactor

  def call
    user = context.user
    user.increment(:subscription_credits, context.product.credits)
    user.save!
  end
end
