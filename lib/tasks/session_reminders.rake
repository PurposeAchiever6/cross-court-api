task session_reminders: :environment do
  ReminderReadyQuery.new.tomorrow_user_sessions.find_each do |user_session|
    KlaviyoService.new.event(Event::SESSION_REMINDER, user_session.user, user_session: user_session)
  end
end
