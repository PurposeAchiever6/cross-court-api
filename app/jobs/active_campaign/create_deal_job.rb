module ActiveCampaign
  class CreateDealJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :exponentially_longer, attempts: 5

    def perform(event, user_id, args = {}, pipeline_name = ::ActiveCampaign::Deal::Pipeline::EMAILS)
      user = User.find(user_id)
      ActiveCampaignService.new(pipeline_name:).create_deal(event, user, args)
    end
  end
end
