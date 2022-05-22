module Api
  module V1
    class ApiUserController < ApiController
      before_action :authenticate_user!
    end
  end
end
