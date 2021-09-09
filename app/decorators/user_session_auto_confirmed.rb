class UserSessionAutoConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def save!
    unless user_session.in_cancellation_time?
      user_session.state = :confirmed

      message = if user_session.is_free_session
                  I18n.t('notifier.session_auto_confirmed_first_timers',
                         name: user.first_name,
                         time: user_session.time.strftime(Session::TIME_FORMAT),
                         location: user_session.location.address,
                         app_link: "#{ENV['FRONTENT_URL']}/app")
                else
                  I18n.t('notifier.session_auto_confirmed',
                         name: user.first_name,
                         time: user_session.time.strftime(Session::TIME_FORMAT),
                         location: user_session.location.address)
                end

      SonarService.send_message(user, message)
    end
    user_session.save!
  end
end
