# == Schema Information
#
# Table name: skill_levels
#
#  id          :integer          not null, primary key
#  min         :decimal(2, 1)
#  max         :decimal(2, 1)
#  name        :string
#  description :string
#

FactoryBot.define do
  factory :skill_level do
    name { %w[Basic Advanced].sample }
    description { Faker::Lorem.paragraph }
    min { [1, 2].sample }
    max { [4, 5].sample }
  end
end
