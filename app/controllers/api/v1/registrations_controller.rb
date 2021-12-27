module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      protect_from_forgery with: :exception
      include Api::Concerns::ActAsApiRequest
      after_action :create_external_records, only: :create

      def create
        super
        return unless @resource.persisted?

        ResendVerificationEmailJob.set(wait: 24.hours).perform_later(@resource.id)
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name,
                                     :last_name, :phone_number, :zipcode, :birthday)
      end

      def render_create_success
        render json: { user: resource_data }
      end

      def create_external_records
        return unless @resource.persisted?

        StripeService.create_user(@resource)
        ActiveCampaignService.new.create_update_contact(@resource)
        SonarService.add_update_customer(@resource)
      end
    end
  end
end
