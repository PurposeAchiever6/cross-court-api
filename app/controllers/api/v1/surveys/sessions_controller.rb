module Api
  module V1
    module Surveys
      class SessionsController < Api::V1::ApiUserController
        def create
          SessionsSurveys::Create.call(
            user: current_user,
            rate: params[:rate],
            feedback: params[:feedback]
          )

          head :ok
        end
      end
    end
  end
end
