# == Schema Information
#
# Table name: gallery_photos
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class GalleryPhoto < ApplicationRecord
  has_one_attached :image, dependent: :destroy

  validates :image, presence: true
end
