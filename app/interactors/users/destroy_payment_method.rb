module Users
  class DestroyPaymentMethod
    include Interactor

    def call
      payment_method_id = context.payment_method_id
      user = context.user

      payment_method = user.payment_methods.find(payment_method_id)

      StripeService.destroy_payment_method(payment_method.stripe_id)
      payment_method.destroy!
    end
  end
end
