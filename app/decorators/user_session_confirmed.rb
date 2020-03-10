class UserSessionConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    raise InvalidDateException, I18n.t('api.errors.user_session.invalid_date') if
      Time.current.in_time_zone(time_zone).to_date > date

    user_session.state = :confirmed if user_session.in_confirmation_time? && user_session.reserved?
    user_session.save!
  end
end
