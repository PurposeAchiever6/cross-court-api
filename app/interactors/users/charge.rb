module Users
  class Charge
    include Interactor

    def call
      amount = context.amount
      raise_error = context.raise_error || false

      failure(I18n.t('api.errors.users.charges.amount_not_present'), raise_error) if amount.blank?

      if amount.negative?
        failure(I18n.t('api.errors.users.charges.amount_not_positive'), raise_error)
      end

      user = context.user
      product = context.product
      description = context.description
      discount = context.discount
      payment_method = context.payment_method || user.default_payment_method
      notify_error = context.notify_error || false
      use_cc_cash = context.use_cc_cash || false
      create_payment_on_failure = context.create_payment_on_failure || false

      unless payment_method
        message = I18n.t('api.errors.users.charges.missing_payment_method')
        notify_slack(user, description, message) if notify_error
        failure(message, raise_error)
      end

      user_cc_cash = user.cc_cash

      ActiveRecord::Base.transaction do
        if use_cc_cash && user_cc_cash.positive?
          if user_cc_cash >= amount
            user.update!(cc_cash: user_cc_cash - amount)
            context.paid_with_cc_cash = true
            create_payment(
              user: user,
              amount: 0,
              product: product,
              description: description,
              status: :success,
              discount: discount,
              cc_cash: amount
            )
            return
          else
            amount -= user_cc_cash
            user.update!(cc_cash: 0)
          end
        end

        if amount.positive?
          payment_intent = StripeService.charge(user, payment_method.stripe_id, amount, description)
          payment_intent_id = payment_intent.id
        end

        create_payment(
          user: user,
          amount: amount,
          product: product,
          description: description,
          status: :success,
          payment_method: payment_method,
          payment_intent_id: payment_intent_id,
          discount: discount,
          cc_cash: use_cc_cash ? user_cc_cash : 0
        )

        context.payment_intent_id = payment_intent_id
      end
    rescue Stripe::StripeError => e
      error_message = e.message

      notify_slack(user, description, error_message) if notify_error

      if create_payment_on_failure
        create_payment(
          user: user,
          amount: amount,
          product: product,
          description: description,
          payment_method: payment_method,
          payment_intent_id: context.payment_intent_id,
          status: :error,
          discount: discount,
          cc_cash: user_cc_cash,
          error_message: error_message
        )
      end

      failure(error_message, raise_error)
    end

    private

    def notify_slack(user, description, error_message)
      SlackService.new(user).charge_error(description, error_message)
    end

    def create_payment(
      user:,
      amount:,
      description:,
      status:,
      product: nil,
      payment_method: nil,
      payment_intent_id: nil,
      discount: nil,
      cc_cash: nil,
      error_message: nil
    )
      payment = Payments::Create.call(
        user: user,
        amount: amount,
        product: product,
        description: description,
        payment_method: payment_method,
        payment_intent_id: payment_intent_id,
        status: status,
        discount: discount,
        cc_cash: cc_cash,
        error_message: error_message
      ).payment

      context.payment = payment
    end

    def failure(message, raise_error)
      raise ChargeUserException, message if raise_error

      context.fail!(message: message)
    end
  end
end
