module Users
  class ResendVerificationEmailJob < ApplicationJob
    queue_as :default

    def perform(user_id)
      user = User.find_by(id: user_id)

      return if !user || user.confirmed?

      user.send_confirmation_instructions
      ActiveCampaignService.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).create_deal(
        ::ActiveCampaign::Deal::Event::DID_NOT_VERIFY_EMAIL,
        user
      )
    end
  end
end
