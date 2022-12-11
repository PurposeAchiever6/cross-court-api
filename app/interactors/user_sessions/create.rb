module UserSessions
  class Create
    include Interactor

    def call
      user = context.user
      session = context.session
      shooting_machine = context.shooting_machine
      date = context.date
      goal = context.goal
      scouting = context.scouting
      referral_code = context.referral_code || nil
      not_charge_user_credit = context.not_charge_user_credit || false
      from_waitlist = context.from_waitlist || false

      UserSessions::InitialValidations.call(user: user, date: date, session: session)

      user_session =
        if session.open_club?
          UserSessions::CreateOpenClub.call(
            session: session,
            user: user,
            date: date,
            goal: goal,
            shooting_machine: shooting_machine,
            from_waitlist: from_waitlist
          )
        else
          UserSessions::CreateNormal.call(
            user: user,
            session: session,
            date: date,
            referral_code: referral_code,
            not_charge_user_credit: not_charge_user_credit,
            from_waitlist: from_waitlist,
            scouting: scouting
          )
        end.user_session

      context.user_session = user_session
    end
  end
end
