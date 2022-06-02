module Users
  class ResendVerificationEmailJob < ApplicationJob
    queue_as :default

    def perform(user_id)
      user = User.find_by(id: user_id)

      return if !user || user.confirmed?

      user.send_confirmation_instructions
      ActiveCampaignService.new.create_deal(
        ::ActiveCampaign::Deal::Event::RE_CONFIRMATION_INSTRUCTIONS,
        user
      )
    end
  end
end
