class MaximumNumberOfPausesReachedException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.subscriptions.no_more_pauses')

    super(message)
  end
end
