module Waitlists
  class AddUser
    include Interactor

    def call
      session = context.session
      user = context.user
      date = context.date

      if session.invalid_date?(date)
        raise InvalidDateException, I18n.t('api.errors.sessions.invalid_date')
      end

      UserSessionWaitlist.create!(session: session, user: user, date: date)
    end
  end
end
