class ChargeNotShowUpPlayersJob < ApplicationJob
  queue_as :default

  def perform
    UserSession.includes(:user).for_yesterday.confirmed.not_checked_in.find_each do |user_session|
      user = user_session.user

      if user_session.is_free_session
        free_session_payment_intent = user_session.free_session_payment_intent

        StripeService.confirm_intent(free_session_payment_intent) if free_session_payment_intent

        ActiveCampaignService.new(
          pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
        ).create_deal(
          ::ActiveCampaign::Deal::Event::FREE_SESSION_NO_SHOW,
          user
        )
      elsif user.unlimited_credits?
        Users::Charge.call(
          user: user,
          price: ENV['UNLIMITED_CREDITS_NO_SHOW_UP_FEE'].to_f,
          description: 'Unlimited membership no show fee'
        )
      end
    end
  end
end
