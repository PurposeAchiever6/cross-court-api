module Api
  module V1
    module ActiveCampaign
      class ContactsController < Api::V1::ApiUserController
        skip_before_action :authenticate_user!

        def create
          active_campaign_service = ActiveCampaignService.new

          response = active_campaign_service.create_update_contact(user)
          contact = response['contact']

          active_campaign_service.add_contact_to_list(
            ::ActiveCampaign::Contact::List::MASTER_LIST,
            contact['id']
          )

          render json: { contact: }
        end

        private

        def user
          OpenStruct.new(params[:contact])
        end
      end
    end
  end
end
