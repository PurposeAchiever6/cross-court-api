class ConfirmedUserSession
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    raise InvalidDateException, I18n.t('api.errors.user_session.invalid_date') unless
      user_session.in_confirmation_time?

    user_session.state = :confirmed if user_session.reserved?
    user_session.save!
  end
end
