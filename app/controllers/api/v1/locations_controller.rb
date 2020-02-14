module Api
  module V1
    class LocationsController < Api::V1::ApiController
      def index
        @locations = Location.includes(image_attachment: :blob)
      end
    end
  end
end
