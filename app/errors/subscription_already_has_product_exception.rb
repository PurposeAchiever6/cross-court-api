class SubscriptionAlreadyHasProductException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.already_has_product')

    super(message)
  end
end
