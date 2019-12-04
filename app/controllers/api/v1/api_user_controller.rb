module Api
  module V1
    class ApiUserController < ApiController
      include DeviseTokenAuth::Concerns::SetUserByToken

      before_action :authenticate_user!
    end
  end
end
