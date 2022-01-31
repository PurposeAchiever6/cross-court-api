class RefereeSessionRemindersJob < ApplicationJob
  queue_as :default

  def perform
    return unless ENV['REFEREE_SESSIONS_NOTIFICATIONS_ENABLED'] == 'true'

    # 24 hour reminder
    SessionReminderQuery.new(
      RefereeSession.all.future.unconfirmed
    ).in_24_hours.find_each do |referee_session|
      user = referee_session.user
      SonarService.send_message(user, I18n.t('notifier.referee_tomorrow_reminder',
                                             name: user.first_name,
                                             time: referee_session.time.strftime(
                                               Session::TIME_FORMAT
                                             ),
                                             location: referee_session.location.name))
    end

    # 12 hour reminder
    SessionReminderQuery.new(
      RefereeSession.all.future.unconfirmed
    ).in(12).find_each do |referee_session|
      user = referee_session.user
      SonarService.send_message(user, I18n.t('notifier.referee_today_reminder',
                                             name: user.first_name,
                                             time: referee_session.time.strftime(
                                               Session::TIME_FORMAT
                                             ),
                                             location: referee_session.location.name))
    end
  end
end
