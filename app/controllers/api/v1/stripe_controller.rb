module Api
  module V1
    class StripeController < ApplicationController
      skip_before_action :verify_authenticity_token

      STRIPE_WEBHOOK_SECRET = ENV.fetch('STRIPE_WEBHOOK_SECRET', nil)
      INVOICE_PAYMENT_FAILED = 'invoice.payment_failed'.freeze
      INVOICE_PAYMENT_SUCCEEDED = 'invoice.payment_succeeded'.freeze
      INVOICE_MARKED_UNCOLLECTIBLE = 'invoice.marked_uncollectible'.freeze
      CUSTOMER_SUBSCRIPTION_UPDATED = 'customer.subscription.updated'.freeze
      CUSTOMER_SUBSCRIPTION_DELETED = 'customer.subscription.deleted'.freeze
      SUBSCRIPTION_CYCLE = 'subscription_cycle'.freeze
      SUBSCRIPTION_UPDATE = 'subscription_update'.freeze
      CHARGE_REFUNDED = 'charge.refunded'.freeze

      def webhook
        payload = request.body.read
        sig_header = request.env['HTTP_STRIPE_SIGNATURE'].freeze
        event = nil

        begin
          event = Stripe::Webhook.construct_event(payload, sig_header, STRIPE_WEBHOOK_SECRET)
        rescue JSON::ParserError, Stripe::SignatureVerificationError
          head :bad_request
          return
        end

        data = event.data
        object = data.object
        type = event.type
        user = User.find_by(stripe_id: object.customer)

        return head :ok unless user

        active_subscription = user.active_subscription

        case type
        when INVOICE_PAYMENT_FAILED
          return unless object.billing_reason == SUBSCRIPTION_CYCLE

          subscription = user.subscriptions.find_by(stripe_id: object.subscription)
          stripe_charge_id = object.charge

          stripe_charge = StripeService.retrieve_charge(stripe_charge_id) if stripe_charge_id

          create_payment(
            subscription:,
            description_reason: :renewal,
            stripe_invoice: object,
            status: :error,
            error_message: stripe_charge&.failure_message
          )

          ::ActiveCampaign::CreateDealJob.perform_later(
            ::ActiveCampaign::Deal::Event::MEMBERSHIP_PAYMENT_FAILED,
            user.id,
            {},
            ::ActiveCampaign::Deal::Pipeline::CROSSCOURT_MEMBERSHIP_FUNNEL
          )

          if !subscription.canceled? && !object.next_payment_attempt
            # next_payment_attempt will be nil on the latest attempt
            # in that case we can safely cancel the user subscription
            Subscriptions::CancelSubscription.call(user:, subscription:)
          end
        when INVOICE_PAYMENT_SUCCEEDED
          if object.subscription
            # Some invoices are done manually and are unrelated to a subscription
            subscription = StripeService.retrieve_subscription(object.subscription)
            update_database_subscription(subscription)
          end

          if active_subscription && object.billing_reason == SUBSCRIPTION_UPDATE
            create_payment(
              subscription: active_subscription,
              description_reason: :update,
              stripe_invoice: object,
              status: :success
            )
          end

          if active_subscription && object.billing_reason == SUBSCRIPTION_CYCLE
            Subscriptions::RenewUserSubscriptionCredits.call(
              user:,
              subscription: active_subscription
            )

            Subscriptions::ApplyCcCashJob.perform_later(user.id, active_subscription.id)

            create_payment(
              subscription: active_subscription,
              description_reason: :renewal,
              stripe_invoice: object,
              status: :success
            )
          end
        when CUSTOMER_SUBSCRIPTION_DELETED
          update_database_subscription(object)
          Subscriptions::ResetUserSubscriptionCredits.call(user:)
        when CUSTOMER_SUBSCRIPTION_UPDATED
          update_database_subscription(object)
        when INVOICE_MARKED_UNCOLLECTIBLE
          actual_subscription_pause = active_subscription.subscription_pauses.actual.last
          if active_subscription && actual_subscription_pause&.paid?
            Users::Charge.call(
              user:,
              amount: ENV['PAID_SUBSCRIPTION_PAUSE_PRICE'].to_f,
              description: 'Membership pause fee',
              chargeable: actual_subscription_pause,
              create_payment_on_failure: true,
              notify_error: true,
              raise_error: false
            )
          end
        when CHARGE_REFUNDED
          payment = Payment.find_by(stripe_id: object.payment_intent)
          if payment
            Payments::Refund.call(
              payment:,
              amount_refunded: object.amount_refunded / 100.00
            )
          end
        else
          Rails.logger.info "Stripe webhooks - unhandled event: #{type}"
        end

        head :ok
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

      def create_payment(subscription:,
                         stripe_invoice:,
                         status:,
                         description_reason:,
                         error_message: nil)
        discount_amount = stripe_invoice.total_discount_amounts.map(&:amount).reduce(:+) || 0
        payment_intent_id = stripe_invoice.payment_intent

        # payment_intent can be nil when invoice amount is zero
        return if payment_intent_id && Payment.find_by(stripe_id: payment_intent_id).present?

        Payments::Create.call(
          chargeable: subscription.product,
          user: subscription.user,
          amount: stripe_invoice.amount_due / 100.00,
          description: "#{subscription.name} (#{description_reason})",
          payment_method: subscription.payment_method,
          payment_intent_id:,
          status:,
          discount: discount_amount / 100.00,
          error_message:
        )
      end
    end
  end
end
