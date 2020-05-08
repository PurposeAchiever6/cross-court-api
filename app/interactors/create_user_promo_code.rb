class CreateUserPromoCode
  include Interactor

  def call
    promo_code = context.promo_code
    return if promo_code.blank?

    UserPromoCode.create!(user: context.user, promo_code: promo_code)
  end
end
