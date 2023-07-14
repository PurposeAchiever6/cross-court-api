module ActiveCampaign
  class CreateUpdateContactAndAddToListJob < ApplicationJob
    queue_as :default

    def perform(user_id, user_attrs = nil)
      user = user_attrs ? User.new(user_attrs) : User.find(user_id)

      active_campaign_service = ActiveCampaignService.new

      response = active_campaign_service.create_update_contact(user)

      contact = response['contact']

      active_campaign_service.add_contact_to_list(
        ::ActiveCampaign::Contact::List::MASTER_LIST,
        contact['id']
      )
    end
  end
end
