class ResetUserSubscriptionCredits
  include Interactor

  def call
    user = context.user
    user.subscription_credits = 0
    user.save!
  end
end
