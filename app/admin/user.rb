ActiveAdmin.register User do
  permit_params :email, :first_name, :last_name, :phone_number, :password, :password_confirmation,
                :is_referee, :is_sem, :image, :confirmed_at, :zipcode

  form do |f|
    type = resource.unlimited_credits? ? 'text' : 'number'

    f.object.confirmed_at = Time.current
    f.inputs 'Details' do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :phone_number
      f.input :credits, input_html: { value: resource.total_credits, type: type, disabled: true }
      f.input :is_referee
      f.input :is_sem
      f.input :image, as: :file
      f.input :confirmed_at, as: :hidden
      f.input :zipcode

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
    column :first_name
    column :last_name
    column :is_sem
    column :is_referee
    column :phone_number
    column :credits, &:total_credits
    column :created_at
    column :zipcode

    actions
  end

  filter :id
  filter :email
  filter :first_name
  filter :last_name
  filter :is_sem
  filter :is_referee
  filter :created_at

  show do
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :image do |user|
        image_tag url_for(user.image) if user.image.attached?
      end
      row :phone_number
      row :credits, &:total_credits
      row :is_referee
      row :is_sem
      row :sign_in_count
      row :zipcode
      row :free_session_state
      row :free_session_expiration_date
      row :created_at
      row :updated_at
    end
  end
end
