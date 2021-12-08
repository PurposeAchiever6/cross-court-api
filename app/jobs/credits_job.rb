class CreditsJob < ApplicationJob
  queue_as :default

  def perform
    active_campaign_service = ActiveCampaignService.new

    UsersQuery.new.expired_free_session_users.each do |user|
      user.decrement(:credits)
      user.free_session_state = 'expired'
      user.save!
    end

    UsersQuery.new.expired_drop_in_credit_users.each do |user|
      user.credits = 0
      user.drop_in_expiration_date = nil
      user.save!
    end

    UsersQuery.new.expired_drop_in_credits_in(15.days).each do |user|
      active_campaign_service.create_deal(
        ::ActiveCampaign::Deal::Event::DROP_IN_SESSION_EXPIRE_SOON,
        user
      )
    end

    UsersQuery.new.free_session_not_used_in(7.days).each do |user|
      active_campaign_service.create_deal(
        ::ActiveCampaign::Deal::Event::FREE_SESSION_NOT_USED_IN_7_DAYS,
        user
      )
    end

    UsersQuery.new.free_session_expires_in(15.days).each do |user|
      active_campaign_service.create_deal(
        ::ActiveCampaign::Deal::Event::FREE_SESSION_EXPIRES_SOON,
        user
      )
    end
  end
end
