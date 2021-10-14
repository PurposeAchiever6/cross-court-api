class CreateUserPromoCode
  include Interactor

  def call
    promo_code = context.promo_code
    return if promo_code.blank?

    user_promo_code = UserPromoCode.find_or_create_by!(user: context.user, promo_code: promo_code)

    user_promo_code.increment!(:times_used)
  end
end
