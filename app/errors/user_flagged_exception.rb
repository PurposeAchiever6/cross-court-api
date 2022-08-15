class UserFlaggedException < StandardError
  def initialize(message = nil)
    message ||= I18n.t('api.errors.users.flagged')

    super(message)
  end
end
