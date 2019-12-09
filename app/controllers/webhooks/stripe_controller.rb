module Webhooks
  class StripeController < ApplicationController
    before_action :load_event

    layout false
    respond_to :json

    def events
      send "handle_#{@event.type.gsub('.', '_')}"
    end

    private

    def handle_checkout_session_completed
      ActiveRecord::Base.transaction do
        user.increment(:credits, product.credits)
        user.save!
        Purchase.create!(user: user, product_id: product.id, price: price)
      end
      head :ok
    end

    def object
      @object ||= @event.data.object
    end

    def price
      @price ||= object.display_items[0].amount / 100
    end

    def product
      @product ||= Product.find_by!(stripe_id: object.display_items[0].sku.product)
    end

    def user
      @user ||= User.find_by!(email: object.customer_email)
    end

    def load_event
      payload = request.body.read
      sig_header = request.env['HTTP_STRIPE_SIGNATURE']
      begin
        @event = Stripe::Webhook.construct_event(
          payload, sig_header, ENV['STRIPE_SIGNING_SECRET']
        )
      rescue JSON::ParserError, Stripe::SignatureVerificationError => e
        render json: { error: e.message }, status: :bad_request
      end
    end
  end
end
