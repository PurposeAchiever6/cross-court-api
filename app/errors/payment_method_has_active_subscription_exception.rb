class PaymentMethodHasActiveSubscriptionException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.payment_methods.has_active_subscription')

    super(message)
  end
end
