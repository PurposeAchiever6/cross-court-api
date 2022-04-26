module Users
  class ClaimFreeSession
    include Interactor

    def call
      user = context.user
      payment_method = context.payment_method || user.default_payment_method

      return unless user.free_session_not_claimed?

      if payment_method.present?
        intent = StripeService.create_free_session_intent(user, payment_method.stripe_id)
        user.free_session_payment_intent = intent.id
      end

      user.free_session_state = :claimed
      user.save!
    rescue Stripe::StripeError => e
      context.fail!(message: e.message)
    end
  end
end
