class UnauthorizedException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.unauthorized')

    super(message)
  end
end
