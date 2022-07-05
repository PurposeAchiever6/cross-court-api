module Api
  module V1
    class StripeController < ApplicationController
      skip_before_action :verify_authenticity_token

      STRIPE_WEBHOOK_SECRET = ENV['STRIPE_WEBHOOK_SECRET']
      INVOICE_PAYMENT_FAILED = 'invoice.payment_failed'.freeze
      INVOICE_PAYMENT_SUCCEEDED = 'invoice.payment_succeeded'.freeze
      CUSTOMER_SUBSCRIPTION_UPDATED = 'customer.subscription.updated'.freeze
      CUSTOMER_SUBSCRIPTION_DELETED = 'customer.subscription.deleted'.freeze
      SUBSCRIPTION_CYCLE = 'subscription_cycle'.freeze

      def webhook
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE'].freeze
        event = nil

        begin
          event = Stripe::Webhook.construct_event(payload, sig_header, STRIPE_WEBHOOK_SECRET)
        rescue JSON::ParserError, Stripe::SignatureVerificationError
          head 400
          return
        end

        data = event.data
        object = data.object
        type = event.type
        user = User.find_by(stripe_id: object.customer)

        return head 200 unless user

        active_subscription = user.active_subscription

        case type
        when INVOICE_PAYMENT_FAILED
          return unless object.billing_reason == SUBSCRIPTION_CYCLE

          subscription = user.subscriptions.find_by(stripe_id: object.subscription)
          stripe_charge_id = object.charge

          stripe_charge = StripeService.retrieve_charge(stripe_charge_id) if stripe_charge_id
          create_payment(
            subscription: subscription,
            stripe_invoice: object,
            status: :error,
            error_message: stripe_charge&.failure_message
          )

          if !subscription.canceled? && !object.next_payment_attempt
            # next_payment_attempt will be nil on the latest attempt
            # in that case we can safely cancel the user subscription
            Subscriptions::CancelSubscription.call(user: user, subscription: subscription)
          end
        when INVOICE_PAYMENT_SUCCEEDED
          subscription = StripeService.retrieve_subscription(object.subscription)

          update_database_subscription(subscription)
          if active_subscription && object.billing_reason == SUBSCRIPTION_CYCLE
            Subscriptions::RenewUserSubscriptionCredits.call(
              user: user,
              subscription: active_subscription
            )
            create_payment(
              subscription: active_subscription,
              stripe_invoice: object,
              status: :success
            )
          end
        when CUSTOMER_SUBSCRIPTION_DELETED
          update_database_subscription(object)
          Subscriptions::ResetUserSubscriptionCredits.call(user: user)
        when CUSTOMER_SUBSCRIPTION_UPDATED
          update_database_subscription(object)
        else
          Rails.logger.info "Stripe webhooks - unhandled event: #{type}"
        end

        head 200
      end

      private

      def update_database_subscription(stripe_subscription)
        subscription = Subscription.find_by!(stripe_id: stripe_subscription.id)
        subscription.assign_stripe_attrs(stripe_subscription)
        if stripe_subscription.discount.nil? && subscription.promo_code.present?
          subscription.promo_code = nil
        end
        subscription.save!
      end

      def create_payment(subscription:, stripe_invoice:, status:, error_message: nil)
        discount_amount = stripe_invoice.total_discount_amounts.map(&:amount).reduce(:+) || 0
        payment_intent_id = stripe_invoice.payment_intent

        return if Payment.find_by(stripe_id: payment_intent_id).present?

        Payments::Create.call(
          product: subscription.product,
          user: subscription.user,
          amount: stripe_invoice.total / 100.00,
          description: "#{subscription.name} (renewal)",
          payment_method: subscription.payment_method,
          payment_intent_id: payment_intent_id,
          status: status,
          discount: discount_amount / 100.00,
          error_message: error_message
        )
      end
    end
  end
end
