module SonarService
  extend self

  CUSTOMER_ATTRS = %w[phone_number email first_name last_name].freeze

  def add_update_customer(user)
    phone = user.phone_number
    SendSonar.add_update_customer(
      phone_number: phone,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name
    )
  rescue SendSonar::RequestException => e
    logger.error { "Error when adding/updating customer: #{e.class}: #{e.message} - #{phone}" }
  end

  def send_message(user, message)
    phone = user.phone_number
    SendSonar.message_customer(text: message, to: phone)
  rescue SendSonar::RequestException => e
    logger.error { "Error when sending message: #{e.class}: #{e.message} - #{phone}" }
  end

  def message_received(user, message)
    message = message.downcase.strip

    if positive_message?(message)
      user_session = find_and_confirm_next(user)
      if user_session.present?
        send_message(user, confirmation_msg(user, user_session))
      else
        send_message(user, I18n.t('notifier.sonar.no_session_booked'))
      end
    elsif negative_message?(message)
      user_session = find_and_cancel_user_session(user)
      if user_session.present?
        send_message(user, cancellation_msg)
      else
        send_message(user, I18n.t('notifier.sonar.no_session_booked'))
      end
    else
      send_message(user, I18n.t('notifier.sonar.unreadable_text'))
    end
  end

  def positive_message?(message)
    %w[yes y].include?(message)
  end

  def negative_message?(message)
    %w[no n].include?(message)
  end

  def find_and_confirm_user_session(user)
    user_session = user.user_sessions.future.reserved.ordered_by_date.first

    return unless user_session

    UserSessionConfirmed.new(user_session).save!
  end

  def find_and_confirm_employee_session(user)
    EmployeeSessionConfirmed.new(user).save!
  end

  def find_and_cancel_user_session(user)
    user_session = user.user_sessions.future.not_canceled.ordered_by_date.first

    return unless user_session

    CanceledUserSession.new(user_session).save!
    user_session
  end

  def find_and_confirm_next(user)
    user_session = find_and_confirm_user_session(user)

    return user_session if user_session

    find_and_confirm_employee_session(user) if user.employee?
  end

  def invite_friend(user_session)
    return '' if user_session.session.full?(user_session.date)

    I18n.t('notifier.sonar.invite_friend_msg', link: user_session.invite_link)
  end

  def confirmation_msg(user, user_session)
    return I18n.t('notifier.sonar.employee_session_confirmed') if user.employee?

    today = Time.current.in_time_zone(user_session.time_zone).to_date
    location = user_session.location

    I18n.t(
      'notifier.sonar.session_confirmed',
      when: user_session.date == today ? 'today' : 'tomorrow',
      time: user_session.time.strftime(Session::TIME_FORMAT),
      location: "#{location.name} (#{location.address})",
      invite_friend: invite_friend(user_session)
    )
  end

  def cancellation_msg
    front_end_url = ENV['FRONTENT_URL']

    I18n.t('notifier.sonar.session_canceled', schedule_url: "#{front_end_url}/locations")
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
