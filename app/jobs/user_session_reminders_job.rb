class UserSessionRemindersJob < ApplicationJob
  queue_as :default

  def perform
    klaviyo_service = KlaviyoService.new

    # 24 hour reminder
    SessionReminderQuery.new(UserSession.all.reserved).in_24_hours.find_each do |user_session|
      user = user_session.user
      klaviyo_service.event(Event::SESSION_REMINDER_24_HOURS, user,
                            user_session: user_session)
      SonarService.send_message(user, I18n.t('notifier.tomorrow_reminder',
                                             name: user.first_name,
                                             time: user_session.time.strftime(Session::TIME_FORMAT)))
    end

    # 8 hour reminder
    SessionReminderQuery.new(UserSession.all.reserved).in(8).find_each do |user_session|
      user = user_session.user
      klaviyo_service.event(Event::SESSION_REMINDER_8_HOURS, user_session.user,
                            user_session: user_session)
      SonarService.send_message(user, I18n.t('notifier.today_reminder',
                                             name: user.first_name,
                                             time: user_session.time.strftime(Session::TIME_FORMAT)))
    end

    # 6 hour reminder
    SessionReminderQuery.new(UserSession.all.reserved).in(6).find_each do |user_session|
      user = user_session.user
      klaviyo_service.event(Event::SESSION_REMINDER_6_HOURS, user_session.user,
                            user_session: user_session)
      SonarService.send_message(user, I18n.t('notifier.today_reminder',
                                             name: user.first_name,
                                             time: user_session.time.strftime(Session::TIME_FORMAT)))
    end

    # Ultimatum message
    UltimatumReadyQuery.new.confirmation_pending.find_each do |user_session|
      user = user_session.user
      klaviyo_service.event(Event::SESSION_ULTIMATUM, user_session.user, user_session: user_session)
      SonarService.send_message(user, I18n.t('notifier.ultimatum',
                                             name: user.first_name,
                                             time: user_session.time.strftime(Session::TIME_FORMAT)))
    end
  end
end
