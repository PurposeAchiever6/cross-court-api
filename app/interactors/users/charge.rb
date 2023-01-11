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
      chargeable = context.chargeable
      description = context.description
      discount = context.discount
      payment_method = context.payment_method || user.default_payment_method
      notify_error = context.notify_error || false
      use_cc_cash = context.use_cc_cash || false
      create_payment_on_failure = context.create_payment_on_failure || false
      paid_with_cc_cash = nil
      payment_intent_id = nil

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
            paid_with_cc_cash = true
            create_payment(
              user:,
              amount: 0,
              chargeable:,
              description:,
              status: :success,
              discount:,
              cc_cash: amount
            )
          else
            amount -= user_cc_cash
            user.update!(cc_cash: 0)
          end
        end

        if amount.positive? && !paid_with_cc_cash
          payment_intent = StripeService.charge(user, payment_method.stripe_id, amount, description)
          payment_intent_id = payment_intent.id
        end

        unless paid_with_cc_cash
          create_payment(
            user:,
            amount:,
            chargeable:,
            description:,
            status: :success,
            payment_method:,
            payment_intent_id:,
            discount:,
            cc_cash: use_cc_cash ? user_cc_cash : 0
          )
        end

        context.payment_intent_id = payment_intent_id
        context.paid_with_cc_cash = paid_with_cc_cash
      end
    rescue Stripe::StripeError => e
      error_message = e.message

      notify_slack(user, description, error_message) if notify_error

      if create_payment_on_failure
        create_payment(
          user:,
          amount:,
          chargeable:,
          description:,
          payment_method:,
          payment_intent_id: context.payment_intent_id,
          status: :error,
          discount:,
          cc_cash: user_cc_cash,
          error_message:
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
      chargeable: nil,
      payment_method: nil,
      payment_intent_id: nil,
      discount: nil,
      cc_cash: nil,
      error_message: nil
    )
      payment = Payments::Create.call(
        user:,
        amount:,
        chargeable:,
        description:,
        payment_method:,
        payment_intent_id:,
        status:,
        discount:,
        cc_cash:,
        error_message:
      ).payment

      context.payment = payment
    end

    def failure(message, raise_error)
      raise ChargeUserException, message if raise_error

      context.fail!(message:)
    end
  end
end
