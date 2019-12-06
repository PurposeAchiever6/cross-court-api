class StripeService
  def self.create_sku(sku_params)
    Stripe::SKU.create(
      attributes: {
        name: sku_params[:name],
        credits: sku_params[:credits]
      },
      price: sku_params[:price].to_i * 100,
      currency: 'usd',
      inventory: { type: 'infinite' },
      product: ENV['STRIPE_PRODUCT_ID']
    )
  end

  def self.delete_sku(sku_id)
    Stripe::SKU.delete(sku_id)
  end
end
