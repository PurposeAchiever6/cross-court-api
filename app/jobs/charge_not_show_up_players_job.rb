class ChargeNotShowUpPlayersJob < ApplicationJob
  queue_as :default

  def perform
    UserSession.for_yesterday
               .confirmed
               .not_checked_in
               .no_show_up_fee_not_charged
               .includes(:user)
               .find_each do |user_session|
      user = user_session.user

      if user_session.is_free_session
        UserSessions::ConfirmFreeSessionIntent.call(user_session: user_session)
        create_not_show_free_session_deal(user)
      elsif user.unlimited_credits?
        Users::Charge.call(
          user: user,
          price: ENV['UNLIMITED_CREDITS_NO_SHOW_UP_FEE'].to_f,
          description: 'Unlimited membership no show fee',
          notify_error: true,
          use_cc_cash: true
        )
      end

      user_session.update!(no_show_up_fee_charged: true)
    end
  end

  private

  def create_not_show_free_session_deal(user)
    ActiveCampaignService.new(
      pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
    ).create_deal(
      ::ActiveCampaign::Deal::Event::FREE_SESSION_NO_SHOW,
      user
    )
  rescue ActiveCampaignException
  end
end
