class UserSessionConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    raise InvalidDateException, I18n.t('api.errors.user_session.invalid_confirmation_date') unless in_confirmation_time?

    user_session.state = :confirmed if user_session.reserved?

    KlaviyoService.new.event(
      Event::SESSION_CONFIRMATION,
      user,
      user_session: user_session
    )
    SlackService.new(user, date, time, location).session_confirmed

    user_session.save!
  end
end
