module UserSessions
  class Create
    include Interactor

    def call
      user = context.user
      session = context.session
      shooting_machines = context.shooting_machines
      date = context.date
      goal = context.goal
      scouting = context.scouting
      referral_code = context.referral_code || nil
      not_charge_user_credit = context.not_charge_user_credit || false
      from_waitlist = context.from_waitlist || false

      UserSessions::InitialValidations.call(user:, date:, session:)

      user_session =
        if session.open_club?
          UserSessions::CreateOpenClub.call(
            session:,
            user:,
            date:,
            goal:,
            shooting_machines:,
            from_waitlist:
          )
        else
          UserSessions::CreateNormal.call(
            user:,
            session:,
            date:,
            referral_code:,
            not_charge_user_credit:,
            from_waitlist:,
            scouting:
          )
        end.user_session

      context.user_session = user_session
    end
  end
end
