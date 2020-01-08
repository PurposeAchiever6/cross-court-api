module Api
  module V1
    module Sem
      class SemSessionsController < Api::V1::ApiSemController
        def index
          @upcoming_sessions = current_user.sem_sessions
                                           .future
                                           .order(:date)
                                           .includes(session: [location: [image_attachment: :blob]])
        end
      end
    end
  end
end
