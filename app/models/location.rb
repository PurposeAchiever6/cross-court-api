# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  address    :string           not null
#  lat        :float            not null
#  lng        :float            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  city       :string           default(""), not null
#  zipcode    :string           default(""), not null
#  time_zone  :string           default("America/Los_Angeles"), not null
#  deleted_at :datetime
#  state      :string           default("CA")
#
# Indexes
#
#  index_locations_on_deleted_at  (deleted_at)
#

class Location < ApplicationRecord
  STATES = %w[
    AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI
    MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT
    VT VA WA WV WI WY
  ].freeze

  acts_as_paranoid
  has_many :sessions
  has_one_attached :image, dependent: :purge_now

  validates :name, :address, :lat, :lng, :city, :zipcode, :time_zone, :state, presence: true

  def full_address
    "#{address ? "#{address}," : ''} #{city || ''} #{state || ''} #{zipcode || ''}"
  end
end
