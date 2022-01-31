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
        active_subscription = user.active_subscription

        case type
        when INVOICE_PAYMENT_FAILED
          if active_subscription
            Subscriptions::CancelSubscription.call(user: user, subscription: active_subscription)
          end
        when INVOICE_PAYMENT_SUCCEEDED
          subscription = StripeService.retrieve_subscription(object.subscription)
          update_database_subscription(subscription)
          if object.billing_reason == SUBSCRIPTION_CYCLE
            Subscriptions::RenewUserSubscriptionCredits.call(
              user: user, subscription: active_subscription
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
        subscription.save!
      end
    end
  end
end
