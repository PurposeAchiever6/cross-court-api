ActiveAdmin.register Session do
  permit_params :location_id, :start_time, :recurring, :time
  includes :location

  form do |f|
    f.inputs 'Session Details' do
      f.input :location

      f.input :start_time, as: :datepicker
      f.input :time
      f.select_recurring :recurring, nil, allow_blank: true
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :location_name

    actions
  end

  show do
    attributes_table do
      row :id
      row :start_time
      row :time
      row :recurring do |session|
        IceCube::Rule.from_hash(session.recurring).to_s
      end
      row :location_name
      row :created_at
      row :updated_at
    end
  end
end
