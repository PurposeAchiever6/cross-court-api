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

  def self.create_user(user)
    customer = Stripe::Customer.create(
      email: user.email,
      name: user.name
    )
    user.update!(stripe_id: customer.id)
  end

  def self.create_payment_method(payment_method, user)
    Stripe::PaymentMethod.attach(
      payment_method,
      customer: user.stripe_id
    )
  end

  def self.destroy_payment_method(payment_method)
    Stripe::PaymentMethod.detach(payment_method)
  end

  def self.fetch_payment_methods(user)
    payment_methods = Stripe::PaymentMethod.list(
      customer: user.stripe_id,
      type: 'card'
    )
    payment_methods.data
  end

  def self.charge(user, payment_method, product)
    Stripe::PaymentIntent.create(
      amount: product.price.to_i * 100,
      currency: 'usd',
      payment_method: payment_method,
      customer: user.stripe_id,
      confirm: true
    )
    user.increment(:credits, product.credits)
    user.save!
  end
end
