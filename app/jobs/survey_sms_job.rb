class SurveySmsJob < ApplicationJob
  queue_as :default

  def perform
    UserSessionsQuery.new.free_sessions_last_hour_checked_in.find_each do |user_session|
      user = user_session.user
      SonarService.send_message(user, I18n.t('notifier.sonar.survey_reminder',
                                             name: user.first_name,
                                             survey_link: "#{ENV['FRONTENT_URL']}?openSurvey=true"))
    end
  end
end
