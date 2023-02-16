ActiveAdmin.register AdminUserRole do
  menu parent: 'Roles and Permissions', priority: 4
  permit_params :role_id, :admin_user_id
  includes :role, :admin_user

  form do |f|
    f.inputs do
      f.input :role_id, as: :select, collection: Role.all
      f.input :admin_user_id, as: :select, collection: AdminUser.all
    end

    actions
  end
end
