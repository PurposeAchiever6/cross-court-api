module UserSessions
  class SendBookedEmail
    include Interactor

    def call
      SessionMailer.with(user_session_id: context.user_session.id).session_booked.deliver_later
    end
  end
end
