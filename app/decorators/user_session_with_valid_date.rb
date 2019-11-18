class UserSessionWithValidDate
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    raise InvalidDateException, I18n.t('api.errors.user_session.invalid_date') unless
      session.schedule.occurs_on?(date)

    user_session.save!
  end
end
