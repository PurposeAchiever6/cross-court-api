ActiveAdmin.register SkillLevel do
  menu label: 'Skill Levels', parent: 'Sessions', priority: 6

  permit_params :name, :description, :max, :min

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :description
      f.input :min, step: '.1'
      f.input :max, step: '.1'
    end

    actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :description
    column :min
    column :max

    actions
  end

  show do
    attributes_table do
      row :name
      row :description
      row :min
      row :max
    end
  end
end
