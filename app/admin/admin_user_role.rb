ActiveAdmin.register AdminUserRole do
  menu parent: 'Roles and Permissions', priority: 3

  permit_params :role_id, :admin_user_id

  includes :role, :admin_user

  filter :admin_user
  filter :role

  form do |f|
    f.inputs do
      f.input :admin_user, as: :select, collection: AdminUser.all.order(:email)
      f.input :role, as: :select, collection: Role.all.order(:name)
    end

    actions
  end

  index do
    id_column
    column :admin_user
    column :role
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :admin_user
      row :role
      row :updated_at
      row :created_at
    end
  end
end
