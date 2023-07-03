class SelfCheckInQrInvalidException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.self_check_in.qr_invalid')

    super(message)
  end
end
