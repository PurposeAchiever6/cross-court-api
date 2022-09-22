module UserUpdateRequests
  class Reject
    include Interactor

    def call
      user_update_request = context.user_update_request

      raise UserUpdateRequestIsNotPendingException unless user_update_request.pending?

      user_update_request.rejected!

      user = user_update_request.user

      SonarService.send_message(
        user,
        I18n.t('notifier.sonar.user_update_requests.reject',
               name: user.first_name,
               cc_email: ENV['CC_TEAM_EMAIL'])
      )
    end
  end
end
