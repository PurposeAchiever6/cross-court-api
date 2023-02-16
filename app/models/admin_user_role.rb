# == Schema Information
#
# Table name: admin_user_roles
#
#  id            :bigint           not null, primary key
#  role_id       :bigint           not null
#  admin_user_id :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_admin_user_roles_on_admin_user_id              (admin_user_id)
#  index_admin_user_roles_on_role_id                    (role_id)
#  index_admin_user_roles_on_role_id_and_admin_user_id  (role_id,admin_user_id) UNIQUE
#
class AdminUserRole < ApplicationRecord
  has_paper_trail

  belongs_to :role
  belongs_to :admin_user
end
