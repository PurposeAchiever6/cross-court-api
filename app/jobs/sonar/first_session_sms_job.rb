module Sonar
  class FirstSessionSmsJob < ApplicationJob
    queue_as :default

    def perform(user_session_ids)
      UserSession.where(id: user_session_ids)
                 .checked_in
                 .first_sessions
                 .includes(:user)
                 .each do |user_session|
        user = user_session.user

        SonarService.send_message(
          user,
          I18n.t('notifier.sonar.post_first_session_check_in', name: user.first_name)
        )
      end
    end
  end
end
