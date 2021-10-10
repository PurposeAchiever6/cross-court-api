class UserSessionAutoConfirmed
  delegate_missing_to :@user_session

  attr_reader :user_session

  def initialize(user_session)
    @user_session = user_session
  end

  def invite_friend
    return '' if session.full?(date)

    I18n.t('notifier.invite_friend_msg', link: invite_link)
  end

  def save!
    unless user_session.in_cancellation_time?
      user_session.state = :confirmed

      message =
        if user_session.is_free_session
          I18n.t('notifier.session_auto_confirmed_first_timers',
                 name: user.first_name,
                 time: user_session.time.strftime(Session::TIME_FORMAT),
                 location: "#{location.name} (#{location.address})",
                 invite_friend: invite_friend,
                 app_link: "#{ENV['FRONTENT_URL']}/app")
        else
          I18n.t('notifier.session_auto_confirmed',
                 name: user.first_name,
                 time: user_session.time.strftime(Session::TIME_FORMAT),
                 location: "#{location.name} (#{location.address})",
                 invite_friend: invite_friend)
        end

      SonarService.send_message(user, message)
      KlaviyoService.new.event(Event::SESSION_CONFIRMATION, user_session.user, user_session: user_session)
      SlackService.new(user, date, time, location).session_auto_confirmed
    end
    user_session.save!
  end
end
