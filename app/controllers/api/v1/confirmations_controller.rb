module Api
  module V1
    class ConfirmationsController < DeviseTokenAuth::ConfirmationsController
      def show
        @resource = resource_class.confirm_by_token(resource_params[:confirmation_token])
        if @resource.errors.empty?
          sign_in(@resource)
          redirect_header_options = { account_confirmation_success: true }
          if signed_in?(resource_name)
            token = signed_in_resource.create_token

            if signed_in_resource.free_session_not_claimed? && signed_in_resource.free_session_expiration_date.nil?
              signed_in_resource.free_session_expiration_date = Time.zone.today + User::FREE_SESSION_EXPIRATION_DAYS
              signed_in_resource.increment(:credits)
              KlaviyoService.new.event(Event::FIRST_FREE_CREDIT_ADDED, signed_in_resource)
            end

            signed_in_resource.save!
            redirect_headers = build_redirect_headers(token.token, token.client, redirect_header_options)
            redirect_to_link = signed_in_resource.build_auth_url(redirect_url, redirect_headers)
            KlaviyoService.new.event(Event::ACCOUNT_CONFIRMATION, signed_in_resource)
          else
            redirect_to_link = DeviseTokenAuth::Url.generate(redirect_url, redirect_header_options)
          end
          redirect_to(redirect_to_link)
        else
          raise ActionController::RoutingError, 'Not Found'
        end
      end
    end
  end
end
