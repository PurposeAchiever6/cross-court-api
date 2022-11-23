# == Schema Information
#
# Table name: goals
#
#  id          :integer          not null, primary key
#  category    :integer          not null
#  description :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Goal < ApplicationRecord
  enum category: { mental: 0, social: 1, physical: 2 }

  validates :category, :description, presence: true
end
