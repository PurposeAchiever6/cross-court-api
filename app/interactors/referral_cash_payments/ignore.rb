module ReferralCashPayments
  class Ignore
    include Interactor

    def call
      referral_cash_payment = context.referral_cash_payment

      raise ReferralCashPaymentIsNotPendingException unless referral_cash_payment.pending?

      referral_cash_payment.ignored!
    end
  end
end
