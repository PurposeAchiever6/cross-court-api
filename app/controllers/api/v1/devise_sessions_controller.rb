module Api
  module V1
    class DeviseSessionsController < DeviseTokenAuth::SessionsController
      protect_from_forgery with: :null_session
      include Api::Concerns::ActAsApiRequest

      after_action :create_stripe_user, only: :create

      private

      def resource_params
        params.require(:user).permit(:email, :password)
      end

      def render_create_success
        render json: { user: resource_data }
      end

      def create_stripe_user
        return if @resource.blank? || @resource&.stripe_id.present?

        StripeService.create_user(@resource)
      end
    end
  end
end
