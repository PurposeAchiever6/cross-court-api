module Api
  module V1
    module ActiveCampaign
      class DealsController < Api::V1::ApiUserController
        skip_before_action :authenticate_user!, if: :stay_in_the_loop_event?

        def create
          ActiveCampaignService.new.create_deal(event, user, deal[:args])

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
          if stay_in_the_loop_event?
            OpenStruct.new(
              email: deal_params[:email],
              active_campaign_id: deal_params[:contact_id]
            )
          else
            current_user
          end
        end

        def event
          deal[:event]
        end

        def stay_in_the_loop_event?
          event == ::ActiveCampaign::Deal::Event::STAY_IN_THE_LOOP
        end
      end
    end
  end
end
