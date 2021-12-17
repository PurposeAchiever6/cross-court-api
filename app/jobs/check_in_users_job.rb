class CheckInUsersJob
  include Sidekiq::Worker

  def perform(checked_in_ids)
    active_campaign_service = ActiveCampaignService.new

    UserSession.where(id: checked_in_ids).includes(:user).each do |user_session|
      user = user_session.user
      event =
        if user_session.is_free_session
          ::ActiveCampaign::Deal::Event::FREE_SESSION_CHECK_IN
        else
          ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN
        end

      active_campaign_service.create_deal(event, user)
      active_campaign_service.create_deal(::ActiveCampaign::Deal::Event::TIME_TO_RE_UP, user) if send_time_to_re_up?(user)
    end
  end

  def send_time_to_re_up?(user)
    user.subscription_credits.zero? && user.active_subscription.present?
  end
end
