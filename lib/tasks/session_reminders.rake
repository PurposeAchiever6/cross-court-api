task session_reminders: :environment do
  send_sms_reminders
end

def send_sms_reminders
  user_sessions = ReminderReadyQuery.new.user_sessions
  user_sessions.each do |user_session|
    message = I18n.t('reminders.sms',
                     session_id: user_session.session_id,
                     date: Date.tomorrow.strftime(Session::DATE_FORMAT),
                     frontend_url: ENV['FRONTENT_URL'])
    twilio_service.send_reminder(user_session.user_phone_number, message)
    sleep 1
  end
  user_sessions.update_all(sms_reminder_sent: true)
end

def twilio_service
  @twilio_service ||= TwilioService.new
end
