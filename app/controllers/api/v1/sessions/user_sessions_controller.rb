module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiUserController
        def create
          ActiveRecord::Base.transaction do
            user_session = UserSession.new(
              session_id: params[:session_id],
              user_id: current_user.id,
              date: params[:date]
            )
            user_session = UserSessionSlackNotification.new(user_session)
            user_session = UserSessionAutoConfirmed.new(user_session)
            user_session = UserSessionConsumeCredit.new(user_session)
            user_session = UserSessionWithValidDate.new(user_session)
            user_session = UserSessionNotFull.new(user_session)
            user_session.save!
            KlaviyoService.new
                          .event(Event::SESSION_BOOKED, current_user, user_session: user_session)
          end
        end
      end
    end
  end
end
