module Payments
  class Refund
    include Interactor

    def call
      payment = context.payment
      amount_refunded = context.amount_refunded

      return unless amount_refunded.positive?

      raise PaymentInvalidForRefundException if payment.error? || payment.refunded?

      status = amount_refunded < payment.amount ? :partially_refunded : :refunded

      payment.update!(status:, amount_refunded:)
    end
  end
end
