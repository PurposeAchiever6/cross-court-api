module Users
  class GetReferrals
    include Interactor

    def call
      user = context.user

      user_promo_codes = UserPromoCode.for_promo_code(user.referral_promo_code)
                                      .includes(:user)
                                      .order(created_at: :desc)

      context.list = user_promo_codes
    end
  end
end
