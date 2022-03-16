module Api
  module V1
    class GalleryPhotosController < Api::V1::ApiController
      def index
        @gallery_photos = GalleryPhoto.includes(image_attachment: :blob)
      end
    end
  end
end
