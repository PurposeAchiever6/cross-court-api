module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      protect_from_forgery with: :exception
      include Api::Concerns::ActAsApiRequest
      after_action :create_stripe_user, :create_active_campaign_user, only: :create

      def create
        super
        return unless @resource.persisted?

        ResendVerificationEmailJob.set(wait: 24.hours).perform_later(@resource.id)
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation,
                                     :first_name, :last_name, :phone_number, :zipcode)
      end

      def render_create_success
        render json: { user: resource_data }
      end

      def create_stripe_user
        StripeService.create_user(@resource) if @resource.persisted?
      end

      def create_active_campaign_user
        CreateUpdateActiveCampaignContactJob.perform_now(@resource.id) if @resource.persisted?
      end
    end
  end
end
