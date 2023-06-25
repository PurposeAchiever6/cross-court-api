class MakeDiscount
  include Interactor

  def call
    user = context.user
    promo_code = context.promo_code
    product = context.product
    product_price = product.price(user).to_i
    context.amount = product_price
    context.discount = 0

    return if promo_code.blank?

    promo_code.validate!(user, product)

    context.amount = promo_code.apply_discount(product_price)
    context.discount = promo_code.discount_amount(product_price)
  end
end
