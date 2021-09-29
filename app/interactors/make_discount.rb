class MakeDiscount
  include Interactor

  def call
    user = context.user
    promo_code = context.promo_code
    product = context.product
    context.price = product.price(user).to_i

    return if promo_code.blank?

    if promo_code.still_valid?(user, product)
      context.price = promo_code.apply_discount(context.price)
    else
      context.fail!(message: I18n.t('api.errors.promo_code.invalid'))
    end
  end
end
