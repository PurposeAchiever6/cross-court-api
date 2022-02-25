module Users
  class ClaimFreeSession
    include Interactor

    def call
      user = context.user

      return unless user.free_session_not_claimed?

      payment_method =
        user.payment_methods.find_by(id: context.payment_method_id) || user.default_payment_method

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
