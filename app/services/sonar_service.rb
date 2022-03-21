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
    case
    when positive_message?(message) && user.employee?
      handle_employee_confirmation(user)
    when positive_message?(message)
      handle_user_confirmation(user)
    when negative_message?(message)
      handle_user_cancelation(user)
    else
      send_message(user, I18n.t('notifier.sonar.unreadable_text'))
    end
  end

  def positive_message?(message)
    %w[yes y].include?(message.downcase.strip)
  end

  def negative_message?(message)
    %w[no n].include?(message.downcase.strip)
  end

  def handle_user_confirmation(user)
    future_user_sessions = user.user_sessions.future

    if future_user_sessions.not_canceled.empty?
      send_message(user, I18n.t('notifier.sonar.no_session_booked'))
    end

    user_session = future_user_sessions.reserved.ordered_by_date.first

    if user_session
      UserSessionConfirmed.new(user_session).save!
      send_message(user, confirmation_msg(user, user_session))
    else
      send_message(user, I18n.t('notifier.sonar.no_reserved_session'))
    end
  end

  def handle_user_cancelation(user)
    user_session = user.user_sessions.future.not_canceled.ordered_by_date.first

    if user_session
      CanceledUserSession.new(user_session).save!
      send_message(user, cancellation_msg)
    else
      send_message(user, I18n.t('notifier.sonar.no_session_booked'))
    end
  end

  def handle_employee_confirmation(user)
    user_session = user.user_sessions.future.reserved.ordered_by_date.first

    if user_session
      UserSessionConfirmed.new(user_session).save!
      send_message(user, confirmation_msg(user, user_session))
      return
    end

    employee_session = EmployeeSessionConfirmed.new(user).save!

    if employee_session
      send_message(user, confirmation_msg(user, employee_session))
    else
      send_message(user, I18n.t('notifier.sonar.no_employee_session'))
    end
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
    @logger ||= Rails.logger
  end
end
