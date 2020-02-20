class UserSessionWithValidDate
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    raise InvalidDateException, I18n.t('api.errors.user_session.invalid_date') if
      !session.schedule.occurs_on?(date) || date.past?

    user_session.save!
  end
end
