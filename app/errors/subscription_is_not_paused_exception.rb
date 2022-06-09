class SubscriptionIsNotPausedException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.is_not_paused')

    super(message)
  end
end
