class StripeService
  def self.create_user(user)
    customer = Stripe::Customer.create(
      email: user.email,
      name: user.full_name
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

  def self.charge(user, payment_method, price)
    Stripe::PaymentIntent.create(
      amount: price * 100,
      currency: 'usd',
      payment_method: payment_method,
      customer: user.stripe_id,
      confirm: true
    )
  end

  def self.create_free_session_intent(user, payment_method)
    Stripe::PaymentIntent.create(
      amount: ENV['FREE_SESSION_PRICE'].to_i * 100,
      currency: 'usd',
      payment_method: payment_method,
      customer: user.stripe_id
    )
  end

  def self.confirm_intent(payment_intent)
    Stripe::PaymentIntent.confirm(payment_intent)
  end

  def self.create_price(product_attrs)
    product_name = product_attrs[:name]
    is_one_time = product_attrs[:product_type] == 'one_time'

    price_attrs = {
      currency: 'usd',
      unit_amount: product_attrs[:price].to_i * 100,
      nickname: product_name,
      product: ENV['STRIPE_PRODUCT_ID']
    }

    price_attrs.merge!(recurring: { interval: 'month' }) unless is_one_time

    Stripe::Price.create(price_attrs)
  end

  def self.update_price(price_id, price_attrs)
    Stripe::Price.update(price_id, price_attrs)
  end
end
