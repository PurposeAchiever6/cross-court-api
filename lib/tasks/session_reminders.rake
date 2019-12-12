task session_reminders: :environment do
  send_email_reminders
  send_sms_reminders
end

def send_email_reminders
  user_sessions = ReminderReadyQuery.new.email_pending
  user_sessions.find_each do |user_session|
    email = user_session.user_email
    name = user_session.user_name
    session_id = user_session.session_id
    SessionMailer.delay.reminder(email, name, session_id, Date.tomorrow)
  end
  user_sessions.update_all(email_reminder_sent: true)
end

def send_sms_reminders
  user_sessions = ReminderReadyQuery.new.sms_pending
  user_sessions.find_each do |user_session|
    formatted_date = Date.tomorrow.strftime(Session::DATE_FORMAT)
    confirmation_url = "#{ENV['FRONTENT_URL']}/sessions/#{session_id}?date=#{formatted_date}"

    message = I18n.t('reminder.message')
    twilio_service.send_reminder(user_session.user_phone_number, "#{message} #{confirmation_url}")
    sleep 1 # Twilio has 1 message per second limit
  end
  user_sessions.update_all(sms_reminder_sent: true)
end

def twilio_service
  @twilio_service ||= TwilioService.new
end
