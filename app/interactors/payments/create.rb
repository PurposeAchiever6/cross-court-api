module Payments
  class Create
    include Interactor

    def call
      payment = Payment.create!(
        chargeable: context.chargeable,
        user_id: context.user.id,
        amount: context.amount,
        description: context.description,
        last_4: context&.payment_method&.last_4,
        stripe_id: context.payment_intent_id,
        status: context.status || :success,
        discount: context.discount || 0,
        cc_cash: context.cc_cash || 0,
        error_message: context.error_message
      )

      context.payment = payment
    end
  end
end
