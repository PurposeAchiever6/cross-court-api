class ShootingMachineSessionMismatchException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.shooting_machines.mismatch_session')

    super(message)
  end
end
