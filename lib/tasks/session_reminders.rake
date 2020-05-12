task session_reminders: :environment do
  klaviyo_service = KlaviyoService.new

  # 24 hour reminder
  UserSessionReminderQuery.new.in_24_hours.find_each do |user_session|
    klaviyo_service.event(Event::SESSION_REMINDER_24_HOURS, user_session.user,
                          user_session: user_session)
  end

  # 8 hour reminder
  UserSessionReminderQuery.new.in(8).find_each do |user_session|
    klaviyo_service.event(Event::SESSION_REMINDER_8_HOURS, user_session.user,
                          user_session: user_session)
  end

  # 7 hour reminder
  UserSessionReminderQuery.new.in(7).find_each do |user_session|
    klaviyo_service.event(Event::SESSION_REMINDER_7_HOURS, user_session.user,
                          user_session: user_session)
  end

  # Ultimatum message
  UltimatumReadyQuery.new.confirmation_pending.find_each do |user_session|
    klaviyo_service.event(Event::SESSION_ULTIMATUM, user_session.user, user_session: user_session)
  end
end
