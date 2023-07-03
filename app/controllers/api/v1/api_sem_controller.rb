module Api
  module V1
    class ApiSemController < ApiController
      before_action :authenticate_user!, :authorize_employee!
    end
  end
end
