module UserSessions
  class ConfirmFreeSessionIntent
    include Interactor

    def call
      user_session = context.user_session
      user = user_session.user
      free_session_payment_intent = user_session.free_session_payment_intent

      return unless user_session.is_free_session

      StripeService.confirm_intent(free_session_payment_intent) if free_session_payment_intent
    rescue Stripe::StripeError => e
      SlackService.new(user).charge_error('Free session no show fee', e.message)
    end
  end
end
