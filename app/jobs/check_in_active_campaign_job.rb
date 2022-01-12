class CheckInActiveCampaignJob
  include Sidekiq::Worker

  def perform(user_session_ids)
    active_campaign_service = ActiveCampaignService.new

    UserSession.where(id: user_session_ids).checked_in.includes(:user).each do |user_session|
      user = user_session.user

      event = if user_session.is_free_session
                ::ActiveCampaign::Deal::Event::FREE_SESSION_CHECK_IN
              else
                ::ActiveCampaign::Deal::Event::SESSION_CHECK_IN
              end

      active_campaign_service.create_deal(event, user)

      next unless send_time_to_re_up?(user)

      active_campaign_service.create_deal(::ActiveCampaign::Deal::Event::TIME_TO_RE_UP, user)
    end
  end

  def send_time_to_re_up?(user)
    user.subscription_credits.zero? && user.active_subscription.present?
  end
end
