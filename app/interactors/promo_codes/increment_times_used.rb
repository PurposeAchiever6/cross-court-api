module PromoCodes
  class IncrementTimesUsed
    include Interactor

    def call
      promo_code = context.promo_code

      return unless promo_code

      promo_code.increment!(:times_used)
    end
  end
end
