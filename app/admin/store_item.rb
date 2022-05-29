ActiveAdmin.register StoreItem do
  config.sort_order = 'name_asc'

  menu label: 'Store Items', parent: 'Products'

  permit_params :name, :description, :price

  filter :name
  filter :price

  index do
    selectable_column
    column :name
    column :description
    number_column :price, as: :currency
    column :updated_at
    column :created_at

    actions
  end

  form do |f|
    f.inputs 'Item Details' do
      f.input :name
      f.input :description, hint: 'This will be used for the credit card charge detail.'
      f.input :price, min: 0
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :description
      number_row :price, as: :currency
      row :updated_at
      row :created_at
    end
  end
end
