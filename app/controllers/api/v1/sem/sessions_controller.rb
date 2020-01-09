module Api
  module V1
    module Sem
      class SessionsController < Api::V1::ApiSemController
        def show
          @selected_session = Session.find(id)
          @user_sessions = UserSession.by_session(id).by_date(date).confirmed.includes(:user)
        end

        private

        def id
          @id ||= params[:id]
        end

        def date
          @date ||= params[:date]
        end
      end
    end
  end
end
