# == Schema Information
#
# Table name: session_guests
#
#  id              :bigint           not null, primary key
#  first_name      :string           not null
#  last_name       :string           not null
#  phone_number    :string           not null
#  email           :string           not null
#  access_code     :string           not null
#  state           :integer          default("reserved"), not null
#  user_session_id :bigint
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  checked_in      :boolean          default(FALSE)
#  assigned_team   :string
#
# Indexes
#
#  index_session_guests_on_user_session_id  (user_session_id)
#

FactoryBot.define do
  factory :session_guest do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone_number { Faker::PhoneNumber.cell_phone }
    email { Faker::Internet.unique.email }
    state { 'reserved' }
    user_session
  end
end
