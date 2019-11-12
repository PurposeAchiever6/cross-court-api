module Api
  module V1
    module Sessions
      class UserSessionsController < Api::V1::ApiController
        def create
          UserSession.create!(session_id: params[:session_id], user_id: current_user.id)
        end
      end
    end
  end
end
