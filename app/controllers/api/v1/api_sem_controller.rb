module Api
  module V1
    class ApiSemController < ApiController
      include DeviseTokenAuth::Concerns::SetUserByToken

      before_action :authenticate_user!, :authorize_user!

      private

      def authorize_user!
        return if current_user.is_sem

        raise UnauthorizedException, I18n.t('api.errors.unauthorized')
      end
    end
  end
end
