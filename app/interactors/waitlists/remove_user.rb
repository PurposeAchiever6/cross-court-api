module Waitlists
  class RemoveUser
    include Interactor

    def call
      session = context.session
      user = context.user
      date = context.date

      user_session_waitlist = session.waitlist(date).pending.find_by(user: user)

      raise UserNotInWaitlistException unless user_session_waitlist

      user_session_waitlist.destroy!
    end
  end
end
