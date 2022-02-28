class SubscriptionHasSameProductException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.has_same_product')

    super(message)
  end
end
