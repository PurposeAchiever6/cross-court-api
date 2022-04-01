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
    when positive_message?(message)
      handle_user_confirmation(user)
    when negative_message?(message)
      handle_user_cancellation(user)
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
    if user.user_sessions.future.not_canceled.empty?
      send_message(user, I18n.t('notifier.sonar.no_session_booked'))
    else
      send_message(user, I18n.t('notifier.sonar.no_more_sonar_confirmation'))
    end
  end

  def handle_user_cancellation(user)
    if user.user_sessions.future.not_canceled.empty?
      send_message(user, I18n.t('notifier.sonar.no_session_booked'))
    else
      send_message(user, I18n.t('notifier.sonar.no_more_sonar_cancellation',
                                frontend_url: ENV['FRONTENT_URL']))
    end
  end

  def logger
    @logger ||= Rails.logger
  end
end
