module Api
  module V1
    class LocationsController < Api::V1::ApiController
      def index
        @locations = Location.all
      end
    end
  end
end
