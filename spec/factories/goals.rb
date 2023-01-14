# == Schema Information
#
# Table name: goals
#
#  id          :bigint           not null, primary key
#  category    :integer          not null
#  description :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryBot.define do
  factory :goal do
    category { Goal.categories.keys.sample }
    description { Faker::Lorem.paragraph }
  end
end
