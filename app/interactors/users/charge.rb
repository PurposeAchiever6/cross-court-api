module Users
  class Charge
    include Interactor

    def call
      user = context.user
      price = context.price
      description = context.description
      payment_method = context.payment_method || user.default_payment_method
      notify_error = context.notify_error || false
      use_cc_cash = context.use_cc_cash || false

      unless price.positive?
        context.fail!(message: I18n.t('api.errors.users.charges.price_not_positive'))
      end

      unless payment_method
        message = I18n.t('api.errors.users.charges.missing_payment_method')
        notify_slack(user, description, message) if notify_error
        context.fail!(message: message)
      end

      user_cc_cash = user.cc_cash

      ActiveRecord::Base.transaction do
        if use_cc_cash && user_cc_cash.positive?
          if user_cc_cash >= price
            user.update!(cc_cash: user_cc_cash - price)
            context.paid_with_cc_cash = true
            return
          else
            price -= user_cc_cash
            user.update!(cc_cash: 0)
          end
        end

        payment_intent = StripeService.charge(user, payment_method.stripe_id, price, description)

        context.charge_payment_intent_id = payment_intent.id
      end
    rescue Stripe::StripeError => e
      error_message = e.message
      notify_slack(user, description, error_message) if notify_error
      context.fail!(message: error_message)
    end

    private

    def notify_slack(user, description, error_message)
      SlackService.new(user).charge_error(description, error_message)
    end
  end
end
