class ShootingMachineInvalidSessionException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.shooting_machines.invalid_session')

    super(message)
  end
end
