module Api
  module V1
    class SelfCheckInsController < Api::V1::ApiUserController
      before_action :authorize_employee!

      def qr_data
        qr_data = SelfCheckIns::QrData.call(location_id: params[:location_id])

        @data = qr_data.data
        @refresh_time_ms = qr_data.refresh_time_ms
      end
    end
  end
end
