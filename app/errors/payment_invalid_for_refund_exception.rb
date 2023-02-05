class PaymentInvalidForRefundException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.payments.invalid_for_refund')

    super(message)
  end
end
