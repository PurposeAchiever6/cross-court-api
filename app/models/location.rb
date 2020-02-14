# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  direction  :string           not null
#  lat        :float            not null
#  lng        :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city       :string           default(""), not null
#  zipcode    :string           default(""), not null
#  time_zone  :string           default("America/Los_Angeles"), not null
#  deleted_at :datetime
#
# Indexes
#
#  index_locations_on_deleted_at  (deleted_at)
#

class Location < ApplicationRecord
  acts_as_paranoid
  has_many :sessions
  has_one_attached :image, dependent: :purge_now

  validates :name, :direction, :lat, :lng, :city, :zipcode, :time_zone, presence: true
end
