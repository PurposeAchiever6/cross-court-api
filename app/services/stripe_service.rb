class StripeService
  attr_reader :user, :payment_method

  def initialize(user, payment_method)
    @user = user
    @payment_method = payment_method
  end

  def create_subscription(product)
    user_stripe_id = user.stripe_id
    create_customer if user_stripe_id.blank?

    Stripe::Subscription.create(
      customer: user_stripe_id,
      items: [
        {
          plan: product.stripe_plan_id
        }
      ]
    )
    user.update!(product_id: product.id)
  end

  def create_customer
    customer = Stripe::Customer.create(
      payment_method: payment_method,
      email: user.email,
      invoice_settings: {
        default_payment_method: payment_method
      }
    )
    user.update!(stripe_id: customer.id)
  end
end
