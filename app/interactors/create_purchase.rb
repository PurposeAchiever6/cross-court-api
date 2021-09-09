class CreatePurchase
  include Interactor

  def call
    product = context.product
    product_price = product.price
    discount = context.promo_code&.discount_amount(product_price) || 0

    purchase = Purchase.create!(
      product_id: product.id,
      price: product_price,
      credits: product.credits,
      name: product.name,
      user_id: context.user.id,
      discount: discount
    )

    context.purchase = purchase
  end
end
