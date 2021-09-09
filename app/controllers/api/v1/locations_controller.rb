module Api
  module V1
    class LocationsController < Api::V1::ApiController
      def index
        @locations = Location.includes(images_attachments: :blob)
      end
    end
  end
end
