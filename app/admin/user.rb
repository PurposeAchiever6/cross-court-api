ActiveAdmin.register User do
  menu label: 'Users', parent: 'Users'

  permit_params :email, :first_name, :last_name, :phone_number, :password, :password_confirmation,
                :is_referee, :is_sem, :image, :confirmed_at, :zipcode, :skill_rating,
                :drop_in_expiration_date, :credits, :subscription_credits,
                :subscription_skill_session_credits, :private_access, :birthday, :cc_cash, :source,
                :reserve_team, :instagram_username

  includes active_subscription: :product

  filter :id
  filter :email
  filter :first_name
  filter :last_name
  filter :instagram_username
  filter :is_sem
  filter :is_referee
  filter :skill_rating
  filter :private_access
  filter :source
  filter :created_at

  action_item :resend_confirmation_email, only: [:show] do
    link_to 'Resend Confirmation Email',
            resend_confirmation_email_admin_user_path(id: user.id),
            method: :post,
            data: { confirm: 'Are you sure you want to resend the confirmation email?' }
  end

  action_item :verify_email, only: [:show] do
    link_to 'Verify Email',
            verify_email_admin_user_path(id: user.id),
            method: :post,
            data: { confirm: "Are you sure you want to manually verify user's email?" }
  end

  form do |f|
    type = resource.unlimited_credits? ? 'text' : 'number'
    subscription_credits = resource.unlimited_credits? ? 'Unlimited' : resource.subscription_credits
    subscription_skill_session_credits = if resource.unlimited_skill_session_credits?
                                           'Unlimited'
                                         else
                                           resource.subscription_skill_session_credits
                                         end

    f.object.confirmed_at = Time.current
    f.inputs 'Details' do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :instagram_username
      f.input :phone_number
      f.input :credits, label: 'Drop in credits'
      f.input :subscription_credits,
              input_html: {
                value: subscription_credits,
                type: type,
                disabled: resource.unlimited_credits?
              }
      f.input :total_session_credits,
              input_html: { value: resource.total_session_credits, type: type, disabled: true }
      f.input :subscription_skill_session_credits,
              input_html: {
                value: subscription_skill_session_credits,
                type: resource.unlimited_skill_session_credits? ? 'text' : 'number',
                disabled: resource.unlimited_skill_session_credits?
              }
      f.input :cc_cash, label: 'CC Cash'
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
      f.input :source
      f.input :private_access
      f.input :reserve_team

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
    column :full_name
    column :instagram_username do |user|
      if user.instagram_profile
        link_to user.instagram_username, user.instagram_profile, target: '_blank', rel: 'noopener'
      end
    end
    column :phone_number
    column :membership
    column :total_session_credits
    number_column 'CC Cash', :cc_cash, as: :currency
    column :skill_rating
    column :zipcode
    column :source
    column :private_access
    column :reserve_team
    column :email_confirmed, &:confirmed?

    actions
  end

  show do |user|
    attributes_table do
      row :id
      row :email
      row :first_name
      row :last_name
      row :instagram_username do
        if user.instagram_profile
          link_to user.instagram_username, user.instagram_profile, target: '_blank', rel: 'noopener'
        end
      end
      row :birthday
      row :image do
        image_tag url_for(user.image), class: 'max-w-200' if user.image.attached?
      end
      row :phone_number
      row :membership
      row :drop_in_credits, &:credits
      row :subscription_credits do
        user.unlimited_credits? ? 'Unlimited' : user.subscription_credits
      end
      row :subscription_skill_session_credits do
        if user.unlimited_skill_session_credits?
          'Unlimited'
        else
          user.subscription_skill_session_credits
        end
      end
      row :total_session_credits
      row :drop_in_expiration_date
      number_row 'CC Cash', :cc_cash, as: :currency
      row :referral_code
      row :is_referee
      row :is_sem
      row :sign_in_count
      row :zipcode
      row :free_session_state
      row :free_session_expiration_date
      row :skill_rating
      row :source
      row :private_access
      row :reserve_team
      row :email_confirmed, &:confirmed?
      row 'User Sessions' do
        link_to 'link to user sessions', admin_user_sessions_path(q: { user_id_eq: user.id })
      end
      row 'Stripe Customer' do
        link_to 'link to stripe',
                "https://dashboard.stripe.com/#{'test/' unless Rails.env.production?}customers" \
                "/#{user.stripe_id}",
                target: '_blank',
                rel: 'noopener'
      end
      row :created_at
      row :updated_at
    end

    panel 'Store Items Purchase' do
      render partial: 'store_items_purchase',
             locals: { user: user, store_items: StoreItem.sorted }
    end

    panel 'Membership' do
      render partial: 'subscriptions', locals: {
        user: user,
        products: Product.recurring,
        payment_methods: user.payment_methods
      }
    end
  end

  member_action :purchase, method: :post do
    user = User.find(params[:id])
    store_item = StoreItem.find(params[:store_item_id])
    use_cc_cash = params[:use_cc_cash] == 'true'

    result = Users::Charge.call(
      user: user,
      amount: store_item.price,
      description: store_item.description,
      use_cc_cash: use_cc_cash
    )

    if result.success?
      redirect_to admin_user_path(user.id), notice: 'Purchase made successfully'
    else
      flash[:error] = result.message
      redirect_to admin_user_path(id: user.id)
    end
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_user_path(id: params[:id])
  end

  member_action :resend_confirmation_email, method: :post do
    user = User.find(params[:id])

    if user.confirmed_at
      flash[:error] = 'User has already confirmed his email'
    else
      user.send_confirmation_instructions
      flash[:notice] = 'Confirmation email sent successfully'
    end
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to admin_user_path(id: params[:id])
  end

  member_action :verify_email, method: :post do
    user = User.find(params[:id])

    if user.confirmed_at
      flash[:error] = 'User has already confirmed his email'
    else
      Users::GiveFreeCredit.call(user: user)
      user.update!(confirmed_at: Time.zone.now)
      flash[:notice] = "User's email verified successfully"
    end
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to admin_user_path(id: params[:id])
  end

  member_action :subscriptions, method: :post do
    action_type = params[:action_type]&.to_sym

    product = Product.recurring.find(params[:product_id])
    user = User.find(params[:id])
    payment_method = user.payment_methods.find(params[:payment_method_id])
    promo_code = PromoCode.find_by(code: params[:promo_code])

    if params[:promo_code].present? && promo_code.nil?
      flash[:error] = 'Promo code not found'
      return redirect_to admin_user_path(id: user.id)
    end

    case action_type
    when :create
      result = Subscriptions::PlaceSubscription.call(
        product: product,
        user: user,
        payment_method: payment_method,
        promo_code: promo_code,
        description: product.name
      )
    when :update
      result = Subscriptions::UpdateSubscription.call(
        user: user,
        subscription: user.active_subscription,
        product: product,
        payment_method: payment_method,
        promo_code: promo_code
      )
    when :cancel
      result = Subscriptions::CancelSubscriptionAtPeriodEnd.call(
        user: user,
        subscription: user.active_subscription
      )
    when :reactivate
      result = Subscriptions::SubscriptionReactivation.call(
        user: user,
        subscription: user.active_subscription
      )
    end

    if result.failure?
      flash[:error] = result.message
    else
      flash[:notice] = 'Membership saved correctly'
    end

    redirect_to admin_user_path(user.id)
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_user_path(id: params[:id])
  end
end
