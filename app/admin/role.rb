ActiveAdmin.register Role do
  menu parent: 'Roles and Permissions', priority: 1

  config.sort_order = 'name_asc'

  permit_params :name, permission_ids: []

  filter :name
  filter :permissions

  form do |f|
    f.inputs do
      f.input :name
      f.input :permissions, as: :select
    end

    actions
  end

  index do
    id_column
    column :name
    actions
  end

  show do
    attributes_table do
      row :name
      row :permissions do |role|
        safe_join(
          role.permissions.order(:name).pluck(:name).map do |permission_name|
            content_tag(:div, permission_name)
          end
        )
      end
      row :updated_at
      row :created_at
    end
  end
end
