class SubscriptionAlreadyCanceledException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.already_canceled')

    super(message)
  end
end
