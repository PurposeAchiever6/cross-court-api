ActiveAdmin.register RolePermission do
  menu parent: 'Roles and Permissions', priority: 3
  permit_params :role_id, :permission_id
  includes :role, :permission

  form do |f|
    f.inputs do
      f.input :role_id, as: :select, collection: Role.all
      f.input :permission_id, as: :select, collection: Permission.all
    end

    actions
  end
end
