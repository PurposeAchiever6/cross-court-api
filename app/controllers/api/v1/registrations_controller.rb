module Api
  module V1
    class RegistrationsController < DeviseTokenAuth::RegistrationsController
      protect_from_forgery with: :exception
      include Api::Concerns::ActAsApiRequest

      def create
        ActiveRecord::Base.transaction do
          super do |resource|
            ActiveCampaignService.new.create_update_contact(resource)
            ::ActiveCampaign::AddContactToListJob.perform_later(
              ::ActiveCampaign::Contact::List::MASTER_LIST,
              resource.active_campaign_id
            )

            StripeService.create_user(resource)
            SonarService.add_update_customer(resource)

            ResendVerificationEmailJob.set(wait: 24.hours).perform_later(resource.id)
          end
        end
      rescue StandardError
        render_error(:conflict, I18n.t('api.errors.users.registration.communication'))
      end

      private

      def sign_up_params
        params.require(:user).permit(:email, :password, :password_confirmation, :first_name,
                                     :last_name, :phone_number, :zipcode, :birthday)
      end

      def render_create_success
        render json: { user: resource_data }
      end
    end
  end
end
