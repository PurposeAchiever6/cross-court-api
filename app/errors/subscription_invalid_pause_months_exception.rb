class SubscriptionInvalidPauseMonthsException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.invalid_pause_months')

    super(message)
  end
end
