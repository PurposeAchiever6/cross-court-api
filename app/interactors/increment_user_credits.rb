class IncrementUserCredits
  include Interactor

  def call
    user = context.user
    user.increment(:credits, context.product.credits)
    user.save!
  end
end
