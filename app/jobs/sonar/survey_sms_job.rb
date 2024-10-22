module Sonar
  class SurveySmsJob < ApplicationJob
    queue_as :default

    def perform
      UserSessionsQuery.new.first_sessions_last_hour_checked_in.find_each do |user_session|
        user = user_session.user
        SonarService.send_message(
          user,
          I18n.t(
            'notifier.sonar.survey_reminder',
            name: user.first_name,
            survey_link: "#{ENV.fetch('FRONTENT_URL', nil)}?openSurvey=true"
          )
        )
      end
    end
  end
end
