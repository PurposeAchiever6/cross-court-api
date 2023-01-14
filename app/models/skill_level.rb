# == Schema Information
#
# Table name: skill_levels
#
#  id          :bigint           not null, primary key
#  min         :decimal(2, 1)
#  max         :decimal(2, 1)
#  name        :string
#  description :string
#

class SkillLevel < ApplicationRecord
  has_many :sessions
end
