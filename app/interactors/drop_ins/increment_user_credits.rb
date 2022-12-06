module DropIns
  class IncrementUserCredits
    include Interactor

    def call
      user = context.user
      product = context.product

      credit_type_to_increment = credit_type(product)

      user.increment(credit_type_to_increment, product.credits)

      user.save!
    end

    private

    def credit_type(product)
      if product.season_pass
        :credits_without_expiration
      elsif product.scouting
        :scouting_credits
      else
        :credits
      end
    end
  end
end
