module ActiveCampaign
  class AddContactToListJob < ApplicationJob
    queue_as :default

    def perform(list_name, active_campaign_id)
      ActiveCampaignService.new.add_contact_to_list(list_name, active_campaign_id)
    end
  end
end
