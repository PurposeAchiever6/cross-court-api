class PromoCodeInvalidException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.promo_code.invalid')

    super(message)
  end
end
