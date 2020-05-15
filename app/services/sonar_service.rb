class SonarService
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def add_customer
    SendSonar.add_update_customer(
      phone_number: user.phone_number,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name
    )
  rescue SendSonar::RequestException => e
    Rails.logger(e)
  end

  def send_message(message)
    SendSonar.message_customer(text: message, to: user.phone_number)
  rescue SendSonar::RequestException => e
    Rails.logger(e)
  end

  def message_received(message)
    user_session = user.user_sessions.future.reserved.ordered_by_date.first
    if user_session.present?
      if positive_message?(message)
        UserSessionConfirmed.new(user_session).save!
        send_message(user, I18n.t('notifier.session_confirmed'))
      elsif negative_message?(message)
        CanceledUserSession.new(user_session).save!
        send_message(user, I18n.t('notifier.session_canceled'))
      else
        send_message(user, I18n.t('notifier.unreadable_text'))
      end
    else
      send_message(user, I18n.t('notifier.no_session_booked'))
    end
  end

  def positive_message?
    %w[yes y].include?(message.downcase)
  end

  def negative_message?
    %w[no n].include?(message.downcase)
  end
end
