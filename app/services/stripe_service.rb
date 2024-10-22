class StripeService
  def self.create_user(user)
    customer = Stripe::Customer.create(
      email: user.email,
      name: user.full_name
    )
    user.update!(stripe_id: customer.id)
  end

  def self.delete_user(customer_id)
    Stripe::Customer.delete(customer_id)
  end

  def self.create_payment_method(payment_method_stripe_id, user)
    Stripe::PaymentMethod.attach(
      payment_method_stripe_id,
      customer: user.stripe_id
    )
  end

  def self.destroy_payment_method(payment_method_stripe_id)
    Stripe::PaymentMethod.detach(payment_method_stripe_id)
  end

  def self.fetch_payment_methods(user)
    payment_methods = Stripe::PaymentMethod.list(
      customer: user.stripe_id,
      type: 'card'
    )
    payment_methods.data
  end

  def self.charge(user, payment_method_stripe_id, price, description = nil)
    Stripe::PaymentIntent.create(
      amount: (price.to_f * 100).to_i,
      currency: 'usd',
      payment_method: payment_method_stripe_id,
      customer: user.stripe_id,
      confirm: true,
      description:,
      receipt_email: user.email
    )
  end

  def self.refund(payment_intent_id, amount = nil)
    Stripe::Refund.create(
      payment_intent: payment_intent_id,
      amount: amount.present? ? (amount.to_f * 100).to_i : nil
    )
  end

  def self.create_free_session_intent(user, payment_method_stripe_id)
    Stripe::PaymentIntent.create(
      amount: (ENV['FREE_SESSION_PRICE'].to_f * 100).to_i,
      currency: 'usd',
      payment_method: payment_method_stripe_id,
      customer: user.stripe_id,
      description: 'First Free no show fee'
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
      unit_amount: (product_attrs[:price].to_f * 100).to_i,
      nickname: product_name,
      product: product_attrs[:stripe_product_id]
    }

    price_attrs.merge!(recurring: { interval: 'month' }) unless is_one_time

    Stripe::Price.create(price_attrs)
  end

  def self.update_price(price_id, price_attrs)
    Stripe::Price.update(price_id, price_attrs)
  end

  def self.create_subscription(user, product, payment_method_stripe_id, promo_code = nil)
    subscription_params = {
      customer: user.stripe_id,
      items: [{ price: product.stripe_price_id }],
      default_payment_method: payment_method_stripe_id
    }

    subscription_params.merge!(promotion_code: promo_code.stripe_promo_code_id) if promo_code

    Stripe::Subscription.create(subscription_params)
  end

  def self.update_subscription(
    subscription,
    product,
    payment_method_stripe_id,
    promo_code = nil,
    proration_date = nil
  )
    subscription_stripe_id = subscription.stripe_id

    subscription_params = {
      items: [
        { id: subscription.stripe_item_id, deleted: true },
        { price: product.stripe_price_id }
      ],
      cancel_at_period_end: false,
      default_payment_method: payment_method_stripe_id,
      billing_cycle_anchor: 'now',
      payment_behavior: 'error_if_incomplete'
    }

    if subscription.paused?
      subscription_params[:pause_collection] = ''
      subscription_params[:proration_behavior] = 'none'
    else
      subscription_params[:proration_behavior] = 'always_invoice'
      subscription_params[:proration_date] = proration_date if proration_date
    end

    if promo_code
      subscription_params.merge!(promotion_code: promo_code.stripe_promo_code_id)
    elsif subscription.promo_code
      Stripe::Subscription.delete_discount(subscription_stripe_id)
    end

    Stripe::Subscription.update(subscription_stripe_id, subscription_params)
  end

  def self.update_subscription_price(subscription, stripe_price_id)
    Stripe::Subscription.update(
      subscription.stripe_id,
      items: [
        { id: subscription.stripe_item_id, deleted: true },
        { price: stripe_price_id }
      ],
      proration_behavior: 'none'
    )
  end

  def self.update_subscription_payment_method(subscription, payment_method)
    Stripe::Subscription.update(
      subscription.stripe_id,
      default_payment_method: payment_method.stripe_id
    )
  end

  def self.apply_coupon_to_subscription(subscription, stripe_coupon_id)
    Stripe::Subscription.update(subscription.stripe_id, coupon: stripe_coupon_id)
  end

  def self.pause_subscription(subscription, resumes_at)
    Stripe::Subscription.update(
      subscription.stripe_id,
      pause_collection: {
        behavior: 'mark_uncollectible',
        resumes_at:
      }
    )
  end

  def self.unpause_subscription(subscription)
    Stripe::Subscription.update(
      subscription.stripe_id,
      pause_collection: '',
      billing_cycle_anchor: 'now',
      proration_behavior: 'none',
      payment_behavior: 'error_if_incomplete'
    )
  end

  def self.retrieve_subscription(stripe_subscription_id)
    Stripe::Subscription.retrieve(stripe_subscription_id)
  end

  def self.cancel_subscription(subscription)
    Stripe::Subscription.cancel(subscription.stripe_id)
  end

  def self.cancel_subscription_at_period_end(subscription)
    Stripe::Subscription.update(subscription.stripe_id, cancel_at_period_end: true)
  end

  def self.reactivate_subscription(subscription)
    Stripe::Subscription.update(subscription.stripe_id, cancel_at_period_end: false)
  end

  def self.create_product(product_attrs)
    Stripe::Product.create(
      name: product_attrs[:name],
      metadata: {
        product_type: product_attrs[:product_type]
      }
    )
  end

  def self.update_product(stripe_product_id, product_attrs)
    Stripe::Product.update(stripe_product_id, product_attrs)
  end

  def self.create_coupon(promo_code_attrs, products)
    duration = promo_code_attrs[:duration]
    duration_in_months = promo_code_attrs[:duration_in_months].presence

    coupon_attrs = {
      duration:,
      currency: 'usd',
      duration_in_months:,
      applies_to: { products: products.map(&:stripe_product_id) }
    }

    discount = promo_code_attrs[:discount]
    if promo_code_attrs[:type] == PercentageDiscount.to_s
      coupon_attrs.merge!(percent_off: discount)
    else
      coupon_attrs.merge!(amount_off: (discount.to_f * 100).to_i)
    end

    Stripe::Coupon.create(coupon_attrs)
  end

  def self.delete_coupon(coupon_id)
    Stripe::Coupon.delete(coupon_id)
  end

  def self.create_promotion_code(coupon_id, promo_code_params)
    promo_code_attrs = {
      coupon: coupon_id,
      code: promo_code_params[:code]
    }

    expiration_date = promo_code_params[:expiration_date]

    if expiration_date.present?
      promo_code_attrs.merge!(expires_at: (DateTime.parse(expiration_date) + 1.day).to_i)
    end

    Stripe::PromotionCode.create(promo_code_attrs)
  end

  def self.update_promotion_code(promotion_code_id, promotion_code_params)
    Stripe::PromotionCode.update(promotion_code_id, promotion_code_params)
  end

  def self.retrieve_invoice(invoice_stripe_id)
    Stripe::Invoice.retrieve(invoice_stripe_id)
  end

  def self.upcoming_invoice(
    customer_id,
    subscription_id = nil,
    items = nil,
    proration_date = nil,
    promo_code = nil
  )

    params = {
      customer: customer_id,
      subscription: subscription_id,
      subscription_items: items,
      subscription_proration_date: proration_date,
      subscription_billing_cycle_anchor: 'now'
    }.compact

    params[:coupon] = promo_code ? promo_code.stripe_coupon_id : ''

    Stripe::Invoice.upcoming(params)
  end

  def self.retrieve_charge(stripe_charge_id)
    Stripe::Charge.retrieve(stripe_charge_id)
  end
end
