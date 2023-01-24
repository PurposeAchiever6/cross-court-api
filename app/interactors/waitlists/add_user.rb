module Waitlists
  class AddUser
    include Interactor

    def call
      session = context.session
      user = context.user
      date = context.date

      raise SessionInvalidDateException if session.invalid_date?(date)
      raise SessionIsOutOfSkillLevelException unless session.at_session_level?(user)
      raise UserAlreadyInSessionException if user.not_canceled_user_session?(session, date)

      UserSessionWaitlist.create!(session:, user:, date:, state: :pending)
    end
  end
end
