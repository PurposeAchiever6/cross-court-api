class SubscriptionCancellationRequestIsNotPendingException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscription_cancellation_requests.not_pending')

    super(message)
  end
end
