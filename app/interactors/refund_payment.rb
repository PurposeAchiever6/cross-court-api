class RefundPayment
  include Interactor

  def call
    payment_intent_id = context.payment_intent_id
    amount = context.amount # if nil, all payment amount will be refunded

    StripeService.refund(payment_intent_id, amount)
  rescue Stripe::StripeError => e
    context.fail!(message: e.message)
  end
end
