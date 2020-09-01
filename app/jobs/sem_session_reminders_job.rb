class SemSessionRemindersJob < ApplicationJob
  queue_as :default

  def perform
    klaviyo_service = KlaviyoService.new

    # 24 hour reminder
    SessionReminderQuery.new(SemSession.all.future.unconfirmed).in_24_hours.find_each do |sem_session|
      user = sem_session.user
      klaviyo_service.event(Event::SEM_SESSION_REMINDER_24_HOURS, user, sem_session: sem_session)
      SonarService.send_message(user, I18n.t('notifier.sem_tomorrow_reminder',
                                             name: user.first_name,
                                             time: sem_session.time.strftime(Session::TIME_FORMAT),
                                             location: sem_session.location.name))
    end

    # 12 hour reminder
    SessionReminderQuery.new(SemSession.all.future.unconfirmed).in(12).find_each do |sem_session|
      user = sem_session.user
      klaviyo_service.event(Event::SEM_SESSION_REMINDER_12_HOURS, user, sem_session: sem_session)
      SonarService.send_message(user, I18n.t('notifier.sem_today_reminder',
                                             name: user.first_name,
                                             time: sem_session.time.strftime(Session::TIME_FORMAT),
                                             location: sem_session.location.name))
    end
  end
end
