module Users
  class GetPaymentMethods
    include Interactor

    def call
      user = context.user
      payment_methods = StripeService.fetch_payment_methods(user)

      context.payment_methods = payment_methods
      context.default_payment_method = payment_methods.first
    end
  end
end
