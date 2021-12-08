class CreateUpdateActiveCampaignContactJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    ActiveCampaignService.new.create_update_contact(user)
  end
end
