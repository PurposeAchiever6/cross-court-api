module UserSessions
  class CreateNormal
    include Interactor::Organizer

    around do |interactor|
      ActiveRecord::Base.transaction do
        session = context.session
        user = context.user
        date = context.date
        from_waitlist = context.from_waitlist
        scouting = context.scouting

        raise SessionIsOutOfSkillLevelException unless session.at_session_level?(user)

        if !from_waitlist && session.user_reached_book_limit?(user, date)
          raise UserBookedSessionsLimitPerDayException
        end

        if user.reserve_team && !session.reserve_team_reservation_allowed?(date)
          raise ReserveTeamNotAllowedException
        end

        referral = User.find_by(referral_code: context.referral_code)

        user_session = UserSession.create!(
          session:,
          user:,
          date:,
          referral:,
          scouting:
        )

        context.user_session = user_session
        context.referral = referral

        interactor.call
      end
    end

    organize UserSessions::ValidateDate,
             UserSessions::ConsumeCredit,
             UserSessions::ConsumeScoutingCredit,
             UserSessions::SlackNotification,
             UserSessions::WaitlistConfirm,
             UserSessions::AutoConfirm,
             UserSessions::ReferralCredits,
             UserSessions::SendBookedEmail,
             Events::SessionBooked
  end
end
