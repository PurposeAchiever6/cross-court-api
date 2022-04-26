module PromoCodes
  class CreateUserPromoCode
    include Interactor

    def call
      user = context.user
      promo_code = context.promo_code
      product = context.product

      return unless promo_code

      user_promo_code = UserPromoCode.find_or_create_by!(user: user, promo_code: promo_code)
      user_promo_code.increment!(:times_used)

      product_referral_cc_cash = product.referral_cc_cash

      if promo_code.for_referral && product_referral_cc_cash.positive?
        promo_code.user.increment!(:cc_cash, product_referral_cc_cash)
      end
    end
  end
end
