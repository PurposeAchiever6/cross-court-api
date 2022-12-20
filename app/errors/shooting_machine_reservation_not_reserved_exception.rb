class ShootingMachineReservationNotReservedException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.shooting_machine_reservations.not_reserved')

    super(message)
  end
end
