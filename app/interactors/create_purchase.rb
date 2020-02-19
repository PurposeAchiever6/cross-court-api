class CreatePurchase
  include Interactor

  def call
    product = context.product
    purchase = Purchase.create!(
      product_id: product.id,
      price: product.price,
      credits: product.credits,
      name: product.name,
      user_id: context.user
    )
    context.purchase = purchase
  end
end
