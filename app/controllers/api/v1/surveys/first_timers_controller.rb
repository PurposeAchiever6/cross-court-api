module Api
  module V1
    module Surveys
      class FirstTimersController < Api::V1::ApiUserController
        def create
          FirstTimerSurveys::Create.call(
            user: current_user,
            how_did_you_hear_about_us: params[:how_did_you_hear_about_us]
          )

          head :ok
        end
      end
    end
  end
end
