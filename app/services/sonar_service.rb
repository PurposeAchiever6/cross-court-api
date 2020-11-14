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
      session = find_next_to_confirm(user)
      if session.present?
        send_message(user, confirmation_msg(user, session))
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

  def confirmation_msg(user, user_session)
    return I18n.t('notifier.employee_session_confirmed') if user.employee?

    session_confirmed_msg = I18n.t('notifier.session_confirmed')
    app_instructions_msg = I18n.t('notifier.app_instructions', app_link: "#{ENV['FRONTENT_URL']}/app")

    if user_session.is_free_session
      "#{session_confirmed_msg} #{app_instructions_msg}"
    else
      session_confirmed_msg
    end
  end
end
