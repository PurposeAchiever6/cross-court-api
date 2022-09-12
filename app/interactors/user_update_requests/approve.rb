module UserUpdateRequests
  class Approve
    include Interactor

    def call
      user_update_request = context.user_update_request

      raise UserUpdateRequestIsNotPendingException unless user_update_request.pending?

      user_update_request.user.update!(user_update_request.requested_attributes)

      user_update_request.approved!
    end
  end
end
