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

class Goal < ApplicationRecord
  has_paper_trail

  enum category: { mental: 0, social: 1, physical: 2 }

  validates :category, :description, presence: true
end
