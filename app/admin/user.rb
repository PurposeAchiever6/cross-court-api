ActiveAdmin.register User do
  permit_params :email, :name, :phone_number, :password, :password_confirmation,
                :is_referee, :is_sem, :image, :credits, :confirmed_at

  form do |f|
    f.object.confirmed_at = Time.current
    f.inputs 'Details' do
      f.input :email
      f.input :name
      f.input :phone_number
      f.input :credits
      f.input :is_referee
      f.input :is_sem
      f.input :image, as: :file
      f.input :confirmed_at, as: :hidden

      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end

    actions
  end

  index do
    selectable_column
    id_column
    column :email
    column :name
    column :phone_number
    column :credits
    column :sign_in_count
    column :created_at
    column :updated_at

    actions
  end

  filter :id
  filter :email
  filter :name
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row :id
      row :email
      row :name
      row :image do |user|
        image_tag url_for(user.image) if user.image.attached?
      end
      row :phone_number
      row :credits
      row :is_referee
      row :is_sem
      row :sign_in_count
      row :created_at
      row :updated_at
    end
  end
end
