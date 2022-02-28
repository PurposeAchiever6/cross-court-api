module Users
  class DestroyPaymentMethod
    include Interactor

    def call
      payment_method_id = context.payment_method_id
      user = context.user
      payment_methods = user.payment_methods

      payment_method_to_delete = payment_methods.find(payment_method_id)

      deleted_was_default = payment_method_to_delete.default

      StripeService.destroy_payment_method(payment_method_to_delete.stripe_id)
      payment_method_to_delete.destroy!

      other_payment_method = payment_methods.reload.sorted.first
      other_payment_method.update!(default: true) if deleted_was_default && other_payment_method
    end
  end
end
