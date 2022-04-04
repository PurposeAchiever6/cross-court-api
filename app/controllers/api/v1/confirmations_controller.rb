module Api
  module V1
    class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
      def show
        @resource = resource_class.confirm_by_token(resource_params[:confirmation_token])

        errors = @resource.errors

        if errors.empty?
          sign_in(@resource)
          redirect_header_options = { success: true }
          if signed_in?(resource_name)
            token = signed_in_resource.create_token

            Users::GiveFreeCredit.call(user: signed_in_resource)

            signed_in_resource.save!
            redirect_headers = build_redirect_headers(
              token.token, token.client, redirect_header_options
            )
            redirect_to_link = signed_in_resource.build_auth_url(redirect_url, redirect_headers)
            send_account_confirmation_event
          else
            redirect_to_link = DeviseTokenAuth::Url.generate(redirect_url, redirect_header_options)
          end
        else
          redirect_to_link = DeviseTokenAuth::Url.generate(
            redirect_url,
            success: false,
            error: errors.full_messages.first
          )
        end
        redirect_to(redirect_to_link)
      end

      private

      def send_account_confirmation_event
        ::ActiveCampaign::CreateDealJob.perform_later(
          ::ActiveCampaign::Deal::Event::ACCOUNT_CONFIRMATION,
          signed_in_resource.id
        )
      end
    end
  end
end
