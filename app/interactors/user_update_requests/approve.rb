module UserUpdateRequests
  class Approve
    include Interactor

    def call
      user_update_request = context.user_update_request

      raise UserUpdateRequestIsNotPendingException unless user_update_request.pending?

      user = user_update_request.user

      user.update!(user_update_request.requested_attributes)
      user_update_request.approved!

      SonarService.send_message(
        user,
        I18n.t('notifier.sonar.user_update_requests.approve', name: user.first_name)
      )
    end
  end
end
