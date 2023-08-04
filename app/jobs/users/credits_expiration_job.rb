module Users
  class CreditsExpirationJob < ApplicationJob
    queue_as :default

    def perform
      active_campaign_service = ActiveCampaignService.new

      UsersQuery.new.expired_free_session_users.each do |user|
        user.decrement(:credits) if user.credits.positive?
        user.free_session_state = :expired
        user.save!
      end

      UsersQuery.new.expired_drop_in_credit_users.each do |user|
        user.credits = 0
        user.drop_in_expiration_date = nil
        user.save!
      end

      UsersQuery.new.expired_drop_in_credits_in(25.days).each do |user|
        active_campaign_service.create_deal(
          ::ActiveCampaign::Deal::Event::DROP_IN_SESSION_EXPIRE_SOON,
          user
        )
      end
    end
  end
end
