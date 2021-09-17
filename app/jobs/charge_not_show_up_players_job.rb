class ChargeNotShowUpPlayersJob < ApplicationJob
  queue_as :default

  def perform
    relation = UserSession.includes(:user).for_yesterday

    UserSessionsQuery.new(relation).not_checked_in.find_each do |user_session|
      user = user_session.user

      if user_session.is_free_session
        StripeService.confirm_intent(user_session.free_session_payment_intent)
      elsif user.unlimited_credits?
        ChargeUser.call(
          user: user,
          price: ENV['UNLIMITED_CREDITS_NO_SHOW_UP_FEE'].to_i,
          description: 'Unlimited membership no show fee'
        )
      end
    end
  end
end
