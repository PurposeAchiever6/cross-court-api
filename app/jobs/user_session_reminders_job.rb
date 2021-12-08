class UserSessionRemindersJob < ApplicationJob
  queue_as :default

  def perform
    active_campaign_service = ActiveCampaignService.new

    # 24 hour reminder
    SessionReminderQuery.new(UserSession.all.reserved).in_24_hours.find_each do |user_session|
      user = user_session.user
      active_campaign_service.create_deal(
        ::ActiveCampaign::Deal::Event::SESSION_REMINDER_24_HOURS,
        user,
        user_session_id: user_session.id
      )
      SonarService.send_message(user, I18n.t('notifier.tomorrow_reminder',
                                             name: user.first_name,
                                             time: user_session.time.strftime(Session::TIME_FORMAT)))
    end

    # 8 hour reminder
    SessionReminderQuery.new(UserSession.all.reserved).in(8).find_each do |user_session|
      user = user_session.user
      active_campaign_service.create_deal(
        ::ActiveCampaign::Deal::Event::SESSION_REMINDER_8_HOURS,
        user,
        user_session_id: user_session.id
      )
      SonarService.send_message(user, I18n.t('notifier.today_reminder',
                                             name: user.first_name,
                                             time: user_session.time.strftime(Session::TIME_FORMAT)))
    end

    # 6 hour reminder
    SessionReminderQuery.new(UserSession.all.reserved).in(6).find_each do |user_session|
      user = user_session.user
      active_campaign_service.create_deal(
        ::ActiveCampaign::Deal::Event::SESSION_REMINDER_6_HOURS,
        user,
        user_session_id: user_session.id
      )
      SonarService.send_message(user, I18n.t('notifier.today_reminder',
                                             name: user.first_name,
                                             time: user_session.time.strftime(Session::TIME_FORMAT)))
    end
  end
end
