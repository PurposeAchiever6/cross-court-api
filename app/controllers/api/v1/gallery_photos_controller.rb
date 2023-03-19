module Api
  module V1
    class GalleryPhotosController < Api::V1::ApiController
      def index
        @gallery_photos = GalleryPhoto.includes(image_attachment: :blob).order(id: :desc).page(page)
      end

      private

      def page
        params[:page] || 1
      end
    end
  end
end
