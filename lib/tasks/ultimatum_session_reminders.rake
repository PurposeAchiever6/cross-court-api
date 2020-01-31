task session_reminders: :environment do
  user_sessions = UltimatumReadyQuery.new.confirmation_pending
  user_sessions.find_each do |user_session|
    email = user_session.user_email
    name = user_session.user_name
    session_id = user_session.session_id
    SessionMailer.delay.ultimatum(email, name, session_id, Date.tomorrow)

    formatted_date = Date.tomorrow.strftime(Session::DATE_FORMAT)
    confirmation_url = "#{ENV['FRONTENT_URL']}/sessions/#{session_id}?date=#{formatted_date}"

    message = I18n.t('reminder.ultimatum')
    twilio_service.send_message(user_session.user_phone_number, "#{message} #{confirmation_url}")
    sleep 1 # Twilio has 1 message per second limit
  end
end

def twilio_service
  @twilio_service ||= TwilioService.new
end
