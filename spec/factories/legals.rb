# == Schema Information
#
# Table name: legals
#
#  id         :integer          not null, primary key
#  title      :string           not null
#  text       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_legals_on_title  (title)
#

FactoryBot.define do
  factory :legal do
    title { Faker::Lorem.word }
    text { Faker::Lorem.paragraph }
  end
end
