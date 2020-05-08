class MakeDiscount
  include Interactor

  def call
    promo_code = context.promo_code
    context.price = context.product.price.to_f
    return if promo_code.blank?

    if promo_code.still_valid?(context.user)
      context.price = promo_code.apply_discount(context.price)
    else
      context.fail!(message: I18n.t('api.errors.promo_code.invalid'))
    end
  end
end
