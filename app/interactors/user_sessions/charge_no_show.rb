module UserSessions
  class ChargeNoShow
    include Interactor

    def call
      user_session = context.user_session
      user = user_session.user
      no_show_up_fee = ENV['NO_SHOW_UP_FEE'].to_f

      if user_session.is_free_session
        UserSessions::ConfirmFreeSessionIntent.call(user_session:)
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

      if user_session.first_session? && !user.active_subscription
        ::ActiveCampaign::CreateDealJob.perform_later(
          ::ActiveCampaign::Deal::Event::FIRST_DAY_PASS_NO_SHOW,
          user.id,
          {},
          ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
        )
      end

      user_session.update!(no_show_up_fee_charged: true)
    end
  end
end
