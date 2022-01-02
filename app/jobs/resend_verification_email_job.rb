class ResendVerificationEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    return if user.confirmed?

    user.send_confirmation_instructions
    ActiveCampaignService.new.create_deal(
      ::ActiveCampaign::Deal::Event::RE_CONFIRMATION_INSTRUCTIONS,
      user
    )
  end
end
