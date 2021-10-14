class IncrementTimesUsedPromoCode
  include Interactor

  def call
    promo_code = context.promo_code

    return if promo_code.blank?

    promo_code.increment!(:times_used)
  end
end
