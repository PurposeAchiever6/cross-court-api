class ShootingMachineAlreadyReservedException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.shooting_machines.already_reserved')

    super(message)
  end
end
