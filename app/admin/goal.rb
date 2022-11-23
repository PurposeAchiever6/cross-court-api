ActiveAdmin.register Goal do
  menu label: 'Goals', parent: 'Users', priority: 3

  permit_params :category, :description

  form do |f|
    f.inputs 'Details' do
      f.input :category, as: :select, collection: Goal.categories.keys.to_a
      f.input :description
    end

    f.actions
  end

  index do
    id_column
    column :category do |goal|
      goal.category&.humanize
    end
    column :description
    actions
  end

  show do |goal|
    attributes_table do
      row :id
      row :category do
        goal.category&.humanize
      end
      row :description
    end
  end
end
