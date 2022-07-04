class UserSessionWaitlistConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    user_session.state = :confirmed

    SonarService.send_message(user, session_waitlist_confirmed_message)

    ::ActiveCampaign::CreateDealJob.perform_later(
      ::ActiveCampaign::Deal::Event::SESSION_CONFIRMATION,
      user.id,
      user_session_id: user_session.id
    )

    SlackService.new(user, date, time, location).session_waitlist_confirmed

    user_session.save!
  end

  private

  def session_waitlist_confirmed_message
    I18n.t(
      'notifier.sonar.session_waitlist_confirmed',
      name: user.first_name,
      when: user_session.date_when_format,
      time: user_session.time.strftime(Session::TIME_FORMAT),
      location: "#{location.name} (#{location.address})"
    )
  end
end
