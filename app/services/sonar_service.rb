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
        send_message(user, I18n.t('notifier.no_session_booked'))
      end
    elsif negative_message?(message)
      user_session = find_and_cancel_user_session(user)
      if user_session.present?
        send_message(user, cancellation_msg(user_session))
      else
        send_message(user, I18n.t('notifier.no_session_booked'))
      end
    else
      send_message(user, I18n.t('notifier.unreadable_text'))
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

  def cancellation_text(user_session)
    user_subscription = user_session.user.active_subscription
    in_cancellation_time = user_session.in_cancellation_time?

    if user_session.is_free_session?
      return 'notifier.first_free_session_canceled_in_time' if in_cancellation_time

      return 'notifier.first_free_session_canceled_out_of_time'
    end

    if user_subscription&.unlimited?
      return 'notifier.unlimited_session_canceled_in_time' if in_cancellation_time

      return 'notifier.unlimited_session_canceled_out_of_time'
    end

    if in_cancellation_time
      'notifier.session_canceled_in_time'
    else
      'notifier.session_canceled_out_of_time'
    end
  end

  def cancellation_msg(user_session)
    front_url = ENV['FRONTENT_URL']
    unlimited_session_canceled_out_of_time_fee = ENV['UNLIMITED_CREDITS_CANCELED_OUT_OF_TIME_PRICE']

    I18n.t(
      cancellation_text(user_session),
      schedule_url: "#{front_url}/locations",
      cancellation_period: ENV['CANCELLATION_PERIOD'],
      free_session_exp_days: User::FREE_SESSION_EXPIRATION_DAYS.parts[:days],
      unlimited_session_canceled_out_of_time_fee: unlimited_session_canceled_out_of_time_fee,
      free_session_canceled_out_of_time_fee: ENV['FREE_SESSION_CANCELED_OUT_OF_TIME_PRICE']
    )
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/sonar.log")
  end
end
