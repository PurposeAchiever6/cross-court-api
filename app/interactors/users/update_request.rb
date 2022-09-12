module Users
  class UpdateRequest
    include Interactor

    def call
      user = context.user
      requested_attributes = context.requested_attributes
      reason = context.reason

      user_update_request = UserUpdateRequest.create!(
        user: user,
        requested_attributes: requested_attributes,
        reason: reason
      )

      UserMailer.with(user_update_request_id: user_update_request.id)
                .update_request
                .deliver_later
    end
  end
end
