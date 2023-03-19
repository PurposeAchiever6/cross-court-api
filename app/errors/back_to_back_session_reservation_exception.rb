class BackToBackSessionReservationException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.sessions.back_to_back_reservation')

    super(message)
  end
end
