# == Schema Information
#
# Table name: gallery_photos
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryBot.define do
  factory :gallery_photo do
    image { Rack::Test::UploadedFile.new('spec/fixtures/blank.png', 'image/png') }
  end
end
