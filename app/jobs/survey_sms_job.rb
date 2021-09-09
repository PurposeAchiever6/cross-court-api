class SurveySmsJob < ApplicationJob
  queue_as :default

  def perform
    UserSessionsQuery.new.last_hour_checked_in.find_each do |user_session|
      user = user_session.user
      SonarService.send_message(user, I18n.t('notifier.survey_reminder',
                                             name: user.first_name,
                                             survey_link: "#{ENV['FRONTENT_URL']}/survey"))
    end
  end
end
