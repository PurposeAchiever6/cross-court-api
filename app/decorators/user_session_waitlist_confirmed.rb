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
    user_session_date = user_session.date
    today = Time.current.in_time_zone(user_session.time_zone).to_date

    session_when = case user_session_date
                   when today
                     'today'
                   when today + 1.day
                     'tomorrow'
                   else
                     user_session_date.strftime(Session::DAY_MONTH_NAME_FORMAT)
                   end

    I18n.t(
      'notifier.sonar.session_waitlist_confirmed',
      name: user.first_name,
      when: session_when,
      time: user_session.time.strftime(Session::TIME_FORMAT),
      location: "#{location.name} (#{location.address})"
    )
  end
end
