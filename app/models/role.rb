# == Schema Information
#
# Table name: roles
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_roles_on_name  (name) UNIQUE
#
class Role < ApplicationRecord
  has_paper_trail

  has_many :role_permissions, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  before_save :normalize_name

  private

  def normalize_name
    self.name = name.titleize
  end
end
