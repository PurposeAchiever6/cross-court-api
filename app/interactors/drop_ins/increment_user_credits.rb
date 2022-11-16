module DropIns
  class IncrementUserCredits
    include Interactor

    def call
      user = context.user
      product = context.product

      user.increment(product.season_pass ? :credits_without_expiration : :credits, product.credits)

      user.save!
    end
  end
end
