module UserSessions
  class ChargeNoShow
    include Interactor

    def call
      user_session = context.user_session
      user = user_session.user
      no_show_up_fee = ENV['NO_SHOW_UP_FEE'].to_f

      if user_session.is_free_session
        UserSessions::ConfirmFreeSessionIntent.call(user_session:)
        create_no_show_free_session_deal(user)
      elsif no_show_up_fee.positive?
        Users::Charge.call(
          user:,
          amount: no_show_up_fee,
          description: 'No show up fee',
          notify_error: true,
          use_cc_cash: true,
          create_payment_on_failure: true
        )
      end

      user_session.update!(no_show_up_fee_charged: true)
    end

    private

    def create_no_show_free_session_deal(user)
      ActiveCampaignService.new(
        pipeline_name: ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
      ).create_deal(
        ::ActiveCampaign::Deal::Event::FREE_SESSION_NO_SHOW,
        user
      )
    rescue ActiveCampaignException
      Rollbar.error(e)
    end
  end
end
