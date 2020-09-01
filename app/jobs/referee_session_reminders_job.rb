class RefereeSessionRemindersJob < ApplicationJob
  queue_as :default

  def perform
    klaviyo_service = KlaviyoService.new

    # 24 hour reminder
    SessionReminderQuery.new(RefereeSession.all.future.unconfirmed).in_24_hours.find_each do |referee_session|
      user = referee_session.user
      klaviyo_service.event(Event::REFEREE_SESSION_REMINDER_24_HOURS, user, referee_session: referee_session)
      SonarService.send_message(user, I18n.t('notifier.referee_tomorrow_reminder',
                                             name: user.first_name,
                                             time: referee_session.time.strftime(Session::TIME_FORMAT),
                                             location: referee_session.location.name))
    end

    # 12 hour reminder
    SessionReminderQuery.new(RefereeSession.all.future.unconfirmed).in(12).find_each do |referee_session|
      user = referee_session.user
      klaviyo_service.event(Event::REFEREE_SESSION_REMINDER_12_HOURS, user, referee_session: referee_session)
      SonarService.send_message(user, I18n.t('notifier.referee_today_reminder',
                                             name: user.first_name,
                                             time: referee_session.time.strftime(Session::TIME_FORMAT),
                                             location: referee_session.location.name))
    end
  end
end
