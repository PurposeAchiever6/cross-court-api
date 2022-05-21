# == Schema Information
#
# Table name: locations
#
#  id                        :integer          not null, primary key
#  name                      :string           not null
#  address                   :string           not null
#  lat                       :float            not null
#  lng                       :float            not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  city                      :string           default(""), not null
#  zipcode                   :string           default(""), not null
#  time_zone                 :string           default("America/Los_Angeles"), not null
#  deleted_at                :datetime
#  state                     :string           default("CA")
#  description               :text             default("")
#  free_session_miles_radius :decimal(, )
#
# Indexes
#
#  index_locations_on_deleted_at  (deleted_at)
#

FactoryBot.define do
  factory :location do
    name { Faker::Address.state }
    address { Faker::Address.street_address }
    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
    city { Faker::Address.city }
    zipcode { Faker::Address.zip_code }
    description { Faker::Lorem.paragraph }
    free_session_miles_radius { rand(10) }
  end
end
