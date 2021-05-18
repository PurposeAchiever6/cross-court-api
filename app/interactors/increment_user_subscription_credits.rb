class IncrementUserSubscriptionCredits
  include Interactor

  def call
    user = context.user
    # TODO: increment subscriptions credits
    # user.increment(:credits, context.product.credits)
    user.save!
  end
end
