ActiveAdmin.register Legal do
  menu label: 'Legal', priority: 3

  permit_params :title, :text

  form do |f|
    f.inputs 'Details' do
      f.input :title, as: :select, collection: %w[terms_and_conditions cancelation_policy]
      f.input :text
    end

    actions
  end

  index do
    selectable_column
    id_column
    column :title

    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :text
    end
  end
end
