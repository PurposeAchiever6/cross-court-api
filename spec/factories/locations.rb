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
#

FactoryBot.define do
  factory :location do
    name      { Faker::Address.state }
    direction { Faker::Address.street_address }
    lat       { Faker::Address.latitude }
    lng       { Faker::Address.longitude }
    city      { Faker::Address.city }
    zipcode   { Faker::Address.zip_code }
  end
end
