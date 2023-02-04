module PromoCodes
  class CreateUserPromoCode
    include Interactor

    def call
      user = context.user
      promo_code = context.promo_code
      product = context.product

      return unless promo_code

      user_promo_code = UserPromoCode.find_or_create_by!(user:, promo_code:)
      user_promo_code.increment!(:times_used)

      product_referral_cc_cash = product.referral_cc_cash

      if promo_code.for_referral && product_referral_cc_cash.positive?
        referral_user = promo_code.user
        referral_user.increment!(:cc_cash, product_referral_cc_cash)

        ActiveCampaign::CreateDealJob.perform_later(
          ActiveCampaign::Deal::Event::PROMO_CODE_REFERRAL_SUCCESS,
          referral_user.id,
          referred_id: user.id,
          cc_cash_awarded: product_referral_cc_cash.to_s
        )
      end
    end
  end
end
