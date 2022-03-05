class SubscriptionIsNotActiveException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.is_not_active')

    super(message)
  end
end
