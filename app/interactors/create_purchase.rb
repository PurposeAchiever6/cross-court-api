class CreatePurchase
  include Interactor

  def call
    user = context.user
    product = context.product
    product_price = product.price(user)
    discount = context.promo_code&.discount_amount(product_price) || 0

    purchase = Purchase.create!(
      product_id: product.id,
      price: product_price,
      credits: product.credits,
      name: product.name,
      user_id: user.id,
      discount: discount
    )

    context.purchase = purchase
  end
end
