# == Schema Information
#
# Table name: locations
#
#  id                                 :bigint           not null, primary key
#  name                               :string           not null
#  address                            :string           not null
#  lat                                :float            not null
#  lng                                :float            not null
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  city                               :string           default(""), not null
#  zipcode                            :string           default(""), not null
#  time_zone                          :string           default("America/Los_Angeles"), not null
#  deleted_at                         :datetime
#  state                              :string           default("CA")
#  description                        :text             default("")
#  free_session_miles_radius          :decimal(, )
#  max_sessions_booked_per_day        :integer
#  max_skill_sessions_booked_per_day  :integer
#  late_arrival_minutes               :integer          default(10)
#  late_arrival_fee                   :integer          default(10)
#  allowed_late_arrivals              :integer          default(2)
#  sklz_late_arrival_fee              :integer          default(0)
#  miles_range_radius                 :decimal(, )
#  late_cancellation_fee              :integer          default(10)
#  late_cancellation_reimburse_credit :boolean          default(FALSE)
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

  US = 'US'.freeze

  GOOGLE_MAPS_BASE_URL = 'https://www.google.com/maps/search/?api=1&query='.freeze

  has_paper_trail
  acts_as_paranoid

  has_many :sessions
  has_many :location_notes, dependent: :destroy
  has_many_attached :images, dependent: :purge_now

  validates :name, :address, :lat, :lng, :city, :zipcode, :time_zone, :state,
            :free_session_miles_radius, :late_arrival_fee, :sklz_late_arrival_fee,
            :late_arrival_minutes, :allowed_late_arrivals, presence: true

  geocoded_by :full_address, latitude: :lat, longitude: :lng
  reverse_geocoded_by :lat, :lng

  def full_address
    [address, city, state, US].compact.join(', ')
  end

  def google_maps_link
    "#{GOOGLE_MAPS_BASE_URL}#{full_address}".split.join('+')
  end

  def self_check_in_url
    "#{ENV.fetch('FRONTENT_URL', '')}/locations/#{id}/self-check-in"
  end

  def notes(date)
    location_notes.for_date(date)
  end
end
