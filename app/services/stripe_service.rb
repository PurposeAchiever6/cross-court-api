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

  def self.charge(user, payment_method, price, description = nil)
    Stripe::PaymentIntent.create(
      amount: price * 100,
      currency: 'usd',
      payment_method: payment_method,
      customer: user.stripe_id,
      confirm: true,
      description: description
    )
  end

  def self.refund(payment_intent_id, amount = nil)
    Stripe::Refund.create(
      payment_intent: payment_intent_id,
      amount: amount
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

  def self.create_subscription(user, product, payment_method_id)
    Stripe::Subscription.create(
      customer: user.stripe_id,
      items: [{ price: product.stripe_price_id }],
      default_payment_method: payment_method_id
    )
  end

  def self.update_subscription(subscription, product, payment_method_id)
    Stripe::Subscription.update(
      subscription.stripe_id,
      items: [
        { id: subscription.stripe_item_id, deleted: true },
        { price: product.stripe_price_id }
      ],
      default_payment_method: payment_method_id
    )
  end

  def self.retrieve_subscription(stripe_subscription_id)
    Stripe::Subscription.retrieve(stripe_subscription_id)
  end

  def self.cancel_subscription(subscription)
    Stripe::Subscription.delete(subscription.stripe_id)
  end
end
