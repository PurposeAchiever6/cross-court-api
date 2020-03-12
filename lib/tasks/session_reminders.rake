task session_reminders: :environment do
  klaviyo_service = KlaviyoService.new
  ReminderReadyQuery.new.tomorrow_user_sessions.find_each do |user_session|
    klaviyo_service.event(Event::SESSION_REMINDER, user_session.user, user_session: user_session)
  end
end
