module UserUpdateRequests
  class Ignore
    include Interactor

    def call
      user_update_request = context.user_update_request

      raise UserUpdateRequestIsNotPendingException unless user_update_request.pending?

      user_update_request.ignored!
    end
  end
end
