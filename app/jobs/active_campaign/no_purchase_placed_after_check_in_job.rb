module ActiveCampaign
  class NoPurchasePlacedAfterCheckInJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: :exponentially_longer, attempts: 2

    def perform(user_id)
      user = User.find(user_id)

      return if user.active_subscription

      ActiveCampaignService.new(
        pipeline_name: ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).create_deal(ActiveCampaign::Deal::Event::FIRST_DAY_PASS_CHECKED_IN_NO_PURCHASE, user)
    rescue ActiveCampaignException => e
      Rollbar.error(e)
    end
  end
end
