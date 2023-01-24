module Users
  class UpdateRequest
    include Interactor

    def call
      user = context.user
      requested_attributes = context.requested_attributes
      reason = context.reason

      user_update_request = UserUpdateRequest.create!(
        user:,
        requested_attributes:,
        reason:
      )

      UserMailer.with(user_update_request_id: user_update_request.id)
                .update_request
                .deliver_later
    end
  end
end
