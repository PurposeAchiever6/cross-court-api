module Users
  class CreatePaymentMethod
    include Interactor

    def call
      user = context.user
      payment_method_stripe_id = context.payment_method_stripe_id

      payment_method_data = StripeService.create_payment_method(payment_method_stripe_id, user)
      card_data = payment_method_data.card

      payment_method = PaymentMethod.create!(
        user: user,
        stripe_id: payment_method_data.id,
        brand: card_data.brand,
        exp_month: card_data.exp_month,
        exp_year: card_data.exp_year,
        last_4: card_data.last4,
        default: !user.default_payment_method
      )

      context.payment_method = payment_method
    end
  end
end
