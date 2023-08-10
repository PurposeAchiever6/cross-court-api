module Users
  class CreditsExpirationJob < ApplicationJob
    queue_as :default

    def perform
      UsersQuery.new.expired_free_session_users.each do |user|
        user.decrement(:credits) if user.credits.positive?
        user.free_session_state = :expired
        user.save!
      end

      UsersQuery.new.expired_drop_in_credit_users.each do |user|
        user.credits = 0
        user.drop_in_expiration_date = nil
        user.save!

        next unless user.subscriptions.empty?

        ActiveCampaignService.new(
          pipeline_name: ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
        ).create_deal(
          ::ActiveCampaign::Deal::Event::NON_MEMBER_FIRST_DAY_PASS_EXPIRED,
          user
        )
      end

      UsersQuery.new.expired_drop_in_credits_in(25.days).each do |user|
        ActiveCampaignService.new.create_deal(
          ::ActiveCampaign::Deal::Event::DROP_IN_SESSION_EXPIRE_SOON,
          user
        )
      end
    end
  end
end
