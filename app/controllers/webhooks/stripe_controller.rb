module Webhooks
  class StripeController < ApplicationController
    before_action :load_event!

    layout false
    respond_to :json

    rescue_from InvalidChargeException, with: :render_custom_exception

    def events
      send "handle_#{@event.type.gsub('.', '_')}"
    end

    private

    def handle_plan_created
      Product.find_by!(stripe_id: object.product).update!(stripe_plan_id: object.id)
      head :ok
    end

    def handle_plan_deleted
      Product.find_by!(stripe_id: object.product).update!(stripe_plan_id: nil)
      head :ok
    end

    def handle_product_created
      Product.create!(stripe_id: object.id, name: object.name)
      head :ok
    end

    def handle_product_deleted
      Product.find_by(stripe_id: @event.data.object.id)&.destroy!
      head :ok
    end

    def handle_charge_succeeded
      user.add_credits!
      head :ok
    end

    def object
      @object ||= @event.data.object
    end

    def user
      @user ||= User.find_by(stripe_id: object.customer)
    end

    def load_event!
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

    def render_custom_exception(exception)
      logger.error(exception)
      render json: { error: exception.message }, status: :bad_request
    end
  end
end
