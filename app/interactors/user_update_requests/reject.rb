module UserUpdateRequests
  class Reject
    include Interactor

    def call
      user_update_request = context.user_update_request

      raise UserUpdateRequestIsNotPendingException unless user_update_request.pending?

      user_update_request.rejected!
    end
  end
end
