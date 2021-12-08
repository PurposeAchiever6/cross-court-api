class CreateActiveCampaignDealJob < ApplicationJob
  queue_as :default

  def perform(event, user_id, args = {})
    user = User.find(user_id)
    ActiveCampaignService.new.create_deal(event, user, args)
  end
end
