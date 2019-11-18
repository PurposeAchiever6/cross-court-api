module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiController
        def create
          ActiveRecord::Base.transaction do
            user_session = UserSession.new(
              session_id: params[:session_id],
              user_id: current_user.id,
              date: params[:date]
            )
            user_session = UserSessionWithValidDate.new(user_session)
            user_session = UserSessionEmail.new(user_session)
            user_session.save!
          end
        end
      end
    end
  end
end
