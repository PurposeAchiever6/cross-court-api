module UserSessions
  class CreateOpenClub
    include Interactor::Organizer

    around do |interactor|
      ActiveRecord::Base.transaction do
        user_session = UserSession.create!(
          session: context.session,
          user: context.user,
          date: context.date,
          goal: context.goal
        )

        context.user_session = user_session

        interactor.call
      end
    end

    organize UserSessions::OpenClubValidations,
             UserSessions::ValidateDate
  end
end
