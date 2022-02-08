ActiveAdmin.register User do
  permit_params :email, :first_name, :last_name, :phone_number, :password, :password_confirmation,
                :is_referee, :is_sem, :image, :confirmed_at, :zipcode, :skill_rating, :vaccinated,
                :drop_in_expiration_date, :credits, :private_access, :birthday

  form do |f|
    type = resource.unlimited_credits? ? 'text' : 'number'
    subscription_credits = resource.unlimited_credits? ? 'Unlimited' : resource.subscription_credits

    f.object.confirmed_at = Time.current
    f.inputs 'Details' do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :phone_number
      f.input :credits, label: 'Drop in credits'
      f.input :subscription_credits,
              input_html: { value: subscription_credits,
                            type: type,
                            disabled: true }
      f.input :total_credits,
              input_html: { value: resource.total_credits, type: type, disabled: true }
      f.input :drop_in_expiration_date,
              as: :datepicker,
              input_html: { autocomplete: :off }
      f.input :birthday,
              as: :datepicker,
              datepicker_options: { change_year: true },
              input_html: { autocomplete: :off }
      f.input :is_referee
      f.input :is_sem
      f.input :image, as: :file
      f.input :confirmed_at, as: :hidden
      f.input :zipcode
      f.input :skill_rating
      f.input :private_access
      f.input :vaccinated, label: 'Proof of vaccination?'

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
    column :birthday
    column :is_sem
    column :is_referee
    column :phone_number
    column :total_credits
    column :skill_rating
    column :created_at
    column :zipcode
    column :private_access
    column :vaccinated
    column :email_confirmed, &:confirmed?

    actions
  end

  filter :id
  filter :email
  filter :first_name
  filter :last_name
  filter :is_sem
  filter :is_referee
  filter :skill_rating
  filter :private_access
  filter :created_at

  show do |user|
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :birthday
      row :image do
        image_tag url_for(user.image) if user.image.attached?
      end
      row :phone_number
      row :drop_in_credits, &:credits
      row :subscription_credits do
        user.unlimited_credits? ? 'Unlimited' : user.subscription_credits
      end
      row :total_credits
      row :drop_in_expiration_date
      row :is_referee
      row :is_sem
      row :sign_in_count
      row :zipcode
      row :free_session_state
      row :free_session_expiration_date
      row :skill_rating
      row :private_access
      row :vaccinated
      row :email_confirmed, &:confirmed?
      row :created_at
      row :updated_at
    end

    panel 'Purchase Actions' do
      render partial: 'purchases', locals: {
        user: user,
        jersey_purchase_price: ENV['JERSEY_PURCHASE_PRICE'],
        towel_purchase_price: ENV['TOWEL_PURCHASE_PRICE'],
        water_purchase_price: ENV['WATER_PURCHASE_PRICE']
      }
    end
  end

  member_action :purchase, method: :post do
    user = User.find(params[:id])
    purchase = params[:purchase_type]&.to_sym

    case purchase
    when :jersey
      result = Users::Charge.call(
        user: user,
        price: ENV['JERSEY_PURCHASE_PRICE'].to_f,
        description: 'Jersey purchase'
      )
    when :towel
      result = Users::Charge.call(
        user: user,
        price: ENV['TOWEL_PURCHASE_PRICE'].to_f,
        description: 'Towel purchase'
      )
    when :water
      result = Users::Charge.call(
        user: user,
        price: ENV['WATER_PURCHASE_PRICE'].to_f,
        description: 'Water bottle purchase'
      )
    end

    if result&.failure?
      flash[:error] = result.message
      return redirect_to admin_user_path(id: user.id)
    end

    redirect_to admin_user_path(user.id), notice: 'Purchase made successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_user_path(id: params[:id])
  end
end
