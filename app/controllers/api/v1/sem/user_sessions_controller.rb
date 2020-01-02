module Api
  module V1
    module Sem
      class UserSessionsController < Api::V1::ApiSemController
        def check_in
          UserSession.where(id: params[:ids]).update_all(checked_in: true)
        end
      end
    end
  end
end
