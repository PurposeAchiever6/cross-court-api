module Api
  module V1
    module ActiveCampaign
      class DealsController < Api::V1::ApiUserController
        skip_before_action :authenticate_user!, if: :stay_in_the_loop_event?

        def create
          active_campaign_service = ActiveCampaignService.new

          active_campaign_service.create_deal(event, user, deal[:args])
          if stay_in_the_loop_event?
            active_campaign_service.add_contact_to_list(
              ::ActiveCampaign::Contact::List::MASTER_LIST,
              user.active_campaign_id
            )
          end

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
