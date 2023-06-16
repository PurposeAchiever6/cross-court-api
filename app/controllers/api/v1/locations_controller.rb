module Api
  module V1
    class LocationsController < Api::V1::ApiController
      def index
        @locations = Location.includes(images_attachments: :blob)
      end

      def locations_near_zipcode
        zipcode = params[:zipcode]
        @near = Location.near("#{zipcode}, #{Location::US}", :miles_range_radius).any?

        unless @near
          @nearest_location = Location.near(
            "#{zipcode}, #{Location::US}",
            1_000_000,
            order: 'distance'
          ).first
        end
      rescue SocketError, Timeout::Error, Geocoder::OverQueryLimitError, Geocoder::RequestDenied,
             Geocoder::InvalidRequest, Geocoder::InvalidApiKey, Geocoder::ServiceUnavailable => e
        Rollbar.error(e)
        @near = true
      end
    end
  end
end
