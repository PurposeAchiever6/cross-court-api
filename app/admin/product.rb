ActiveAdmin.register Product do
  permit_params :credits
  actions :all, except: %i[new destroy]

  form do |f|
    f.inputs 'Product details' do
      f.input :credits
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :credits
    end
  end
end
