class UserSessionConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    unless in_confirmation_time?
      raise InvalidDateException, I18n.t('api.errors.user_session.invalid_confirmation_date')
    end

    user_session.state = :confirmed if user_session.reserved?

    ::ActiveCampaign::CreateDealJob.perform_later(
      ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
      user.id,
      user_session_id: user_session.id
    )
    SlackService.new(user, date, time, location).session_confirmed

    user_session.save!
    user_session
  end
end
