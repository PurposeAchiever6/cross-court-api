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
#

class Location < ApplicationRecord
  has_many :sessions, dependent: :destroy
  has_one_attached :image

  validates :name, :direction, :lat, :lng, :city, :zipcode, :time_zone, presence: true
end
