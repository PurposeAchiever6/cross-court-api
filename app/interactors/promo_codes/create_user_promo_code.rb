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

      if promo_code.referral?
        referral_promo_code_actions(user, promo_code, product, user_promo_code)
      end
    end

    private

    def referral_promo_code_actions(user, promo_code, product, user_promo_code)
      referral_user = promo_code.user
      referred_user = user
      product_referral_cc_cash = product.referral_cc_cash
      referral_cash = ENV.fetch('REFERRAL_CASH', 0).to_i

      if product_referral_cc_cash.positive?
        referral_user.increment!(:cc_cash, product_referral_cc_cash)

        ActiveCampaign::CreateDealJob.perform_later(
          ActiveCampaign::Deal::Event::PROMO_CODE_REFERRAL_SUCCESS,
          referral_user.id,
          referred_id: referred_user.id,
          cc_cash_awarded: product_referral_cc_cash.to_s
        )
      end

      if referral_cash.positive?
        ReferralCashPayment.create!(
          status: :pending,
          amount: referral_cash,
          referral: referral_user,
          referred: referred_user,
          user_promo_code:
        )
      end
    end
  end
end
