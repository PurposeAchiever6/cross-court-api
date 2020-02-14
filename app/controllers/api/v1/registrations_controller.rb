module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      protect_from_forgery with: :exception
      include Api::Concerns::ActAsApiRequest
      after_action :create_stripe_user, only: :create

      def create
        super
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation,
                                     :name, :phone_number)
      end

      def render_create_success
        render json: { user: resource_data }
      end

      def create_stripe_user
        StripeService.create_user(@resource) if @resource.persisted?
      end
    end
  end
end
