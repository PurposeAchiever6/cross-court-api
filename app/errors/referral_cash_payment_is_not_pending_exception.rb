class ReferralCashPaymentIsNotPendingException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.referral_cash_payments.not_pending')

    super(message)
  end
end
