module Api
  module V1
    module ActiveCampaign
      class ContactsController < Api::V1::ApiUserController
        skip_before_action :authenticate_user!

        def create
          response = ActiveCampaignService.new.create_update_contact(user)

          render json: { contact: response['contact'] }
        end

        private

        def user
          OpenStruct.new(params[:contact])
        end
      end
    end
  end
end
