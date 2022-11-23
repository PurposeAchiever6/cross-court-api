module Api
  module V1
    class GoalsController < Api::V1::ApiController
      def index
        @goals = Goal.all
      end
    end
  end
end
