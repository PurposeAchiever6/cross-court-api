module Api
  module V1
    class ApiSemController < ApiController
      include DeviseTokenAuth::Concerns::SetUserByToken

      before_action :authenticate_user!, :authorize_employee!

      private

      def authorize_employee!
        return if current_user.employee?

        raise UnauthorizedException, I18n.t('api.errors.unauthorized')
      end
    end
  end
end
