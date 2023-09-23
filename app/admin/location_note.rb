ActiveAdmin.register LocationNote do
  menu label: 'Location Notes', parent: 'Sessions', priority: 2

  permit_params :notes, :date, :admin_user_id, :location_id

  filter :notes
  filter :date
  filter :location
  filter :admin_user

  form do |f|
    create = f.object.new_record?

    f.inputs 'Session guest details' do
      f.input :location
      f.input :notes
      f.input :date
      f.input :admin_user_id, as: :hidden, input_html: { value: current_admin_user.id } if create
    end

    f.actions
  end

  index do
    id_column
    column :location
    column :date
    column :notes
    column :created_by, &:admin_user

    actions
  end

  show do
    attributes_table do
      row :location
      row :date
      row :notes
      row :created_by, &:admin_user
      row :created_at
      row :updated_at
    end
  end
end
