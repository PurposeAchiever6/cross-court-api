module Api
  module V1
    module ActiveCampaign
      class DealsController < Api::V1::ApiUserController
        skip_before_action :authenticate_user!, if: :skip_auth?

        def create
          active_campaign_service = ActiveCampaignService.new

          active_campaign_service.create_deal(event, user, deal[:args])

          head :ok
        end

        private

        def deal
          params[:deal]
        end

        def deal_params
          deal[:params]
        end

        def user
          return current_user if current_user

          OpenStruct.new(
            email: deal_params[:email],
            active_campaign_id: deal_params[:contact_id]
          )
        end

        def event
          deal[:event]
        end

        def skip_auth?
          events = [::ActiveCampaign::Deal::Event::LEAD_MAGNET]
          events.include?(event)
        end
      end
    end
  end
end
