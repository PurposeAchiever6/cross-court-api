class CreateGalleryPhotos < ActiveRecord::Migration[6.0]
  def change
    create_table :gallery_photos, &:timestamps
  end
end
