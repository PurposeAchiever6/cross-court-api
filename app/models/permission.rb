# == Schema Information
#
# Table name: permissions
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Permission < ApplicationRecord
  has_paper_trail

  MANAGE = 'Manage'.freeze
  ABILITIES = [MANAGE].freeze

  def self.ability_resource_name(ability, resource_name)
    "#{ability}::#{resource_name}"
  end
end
