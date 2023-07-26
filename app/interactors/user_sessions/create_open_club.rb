module UserSessions
  class CreateOpenClub
    include Interactor::Organizer

    around do |interactor|
      ActiveRecord::Base.transaction do
        user = context.user
        user_session = UserSession.create!(
          user:,
          session: context.session,
          date: context.date,
          goal: context.goal,
          first_session: user.user_sessions.reserved_or_confirmed.count.zero?
        )

        context.user_session = user_session

        interactor.call
      end
    end

    organize UserSessions::OpenClubValidations,
             UserSessions::ValidateDate,
             ShootingMachineReservations::Create,
             UserSessions::AutoConfirm,
             UserSessions::SendBookedEmail
  end
end
