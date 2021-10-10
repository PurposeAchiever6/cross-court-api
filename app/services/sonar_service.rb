module SonarService
  extend self

  def add_customer(user)
    SendSonar.add_update_customer(
      phone_number: user.phone_number,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name
    )
  rescue SendSonar::RequestException => e
    Rails.logger.error(e)
  end

  def send_message(user, message)
    SendSonar.message_customer(text: message, to: user.phone_number)
  rescue SendSonar::RequestException => e
    Rails.logger.error(e)
  end

  def message_received(user, message)
    if positive_message?(message)
      user_session = find_next_to_confirm(user)
      if user_session.present?
        send_message(user, confirmation_msg(user, user_session))
      else
        send_message(user, I18n.t('notifier.no_session_booked'))
      end
    else
      send_message(user, I18n.t('notifier.unreadable_text'))
    end
  end

  def positive_message?(message)
    %w[yes y].include?(message.downcase)
  end

  def find_next_to_confirm(user)
    if user.employee?
      EmployeeSessionConfirmed.new(user).save!
    else
      user_session = user.user_sessions.future.reserved.ordered_by_date.first

      return unless user_session

      UserSessionConfirmed.new(user_session).save!
      user_session
    end
  end

  def invite_friend(user_session)
    return '' if user_session.session.full?(user_session.date)

    I18n.t('notifier.invite_friend_msg', link: user_session.invite_link)
  end

  def confirmation_msg(user, user_session)
    return I18n.t('notifier.employee_session_confirmed') if user.employee?

    today = Time.current.in_time_zone(user_session.time_zone).to_date
    location = user_session.location

    if user_session.is_free_session
      I18n.t(
        'notifier.session_confirmed_first_timers',
        name: user.first_name,
        when: user_session.date == today ? 'today' : 'tomorrow',
        time: user_session.time.strftime(Session::TIME_FORMAT),
        location: "#{location.name} (#{location.address})",
        invite_friend: invite_friend(user_session),
        app_link: "#{ENV['FRONTENT_URL']}/app"
      )
    else
      I18n.t(
        'notifier.session_confirmed',
        name: user.first_name,
        when: user_session.date == today ? 'today' : 'tomorrow',
        time: user_session.time.strftime(Session::TIME_FORMAT),
        location: "#{location.name} (#{location.address})",
        invite_friend: invite_friend(user_session)
      )
    end
  end
end
