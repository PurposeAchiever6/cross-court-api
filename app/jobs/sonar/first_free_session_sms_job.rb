module Sonar
  class FirstFreeSessionSmsJob < ApplicationJob
    queue_as :default

    def perform(user_session_ids)
      UserSession.where(id: user_session_ids).checked_in.includes(:user).each do |user_session|
        user = user_session.user

        next unless user_session.is_free_session

        SonarService.send_message(
          user,
          I18n.t('notifier.sonar.post_free_session_check_in', name: user.first_name)
        )
      end
    end
  end
end
