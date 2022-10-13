module UserSessions
  class Create
    include Interactor

    def call
      user = context.user
      session = context.session
      date = context.date
      referral_code = context.referral_code || nil
      not_charge_user_credit = context.not_charge_user_credit || false
      from_waitlist = context.from_waitlist || false

      UserSessions::InitialValidations.call(user: user, date: date, session: session)

      user_session =
        if session.open_club?
          UserSessions::CreateOpenClub.call(
            session: session,
            user: user,
            date: date
          )
        else
          UserSessions::CreateNormal.call(
            user: user,
            session: session,
            date: date,
            referral_code: referral_code,
            not_charge_user_credit: not_charge_user_credit,
            from_waitlist: from_waitlist
          )
        end.user_session

      context.user_session = user_session
    end
  end
end
