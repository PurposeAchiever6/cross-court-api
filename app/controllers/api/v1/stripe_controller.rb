module Api
  module V1
    class StripeController < ApplicationController
      skip_before_action :verify_authenticity_token

      STRIPE_WEBHOOK_SECRET = ENV['STRIPE_WEBHOOK_SECRET']
      INVOICE_PAYMENT_FAILED = 'invoice.payment_failed'.freeze
      INVOICE_PAYMENT_SUCCEEDED = 'invoice.payment_succeeded'.freeze
      CUSTOMER_SUBSCRIPTION_UPDATED = 'customer.subscription.updated'.freeze
      CUSTOMER_SUBSCRIPTION_DELETED = 'customer.subscription.deleted'.freeze

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

        case type
        when INVOICE_PAYMENT_FAILED, INVOICE_PAYMENT_SUCCEEDED
          subscription = StripeService.retrieve_subscription(object.subscription)
          update_database_subscription(subscription)
        when CUSTOMER_SUBSCRIPTION_UPDATED, CUSTOMER_SUBSCRIPTION_DELETED
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
