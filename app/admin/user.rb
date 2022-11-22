ActiveAdmin.register User do
  menu label: 'Users', parent: 'Users', priority: 1

  permit_params :email, :first_name, :last_name, :phone_number, :password, :password_confirmation,
                :is_referee, :is_sem, :image, :confirmed_at, :zipcode, :skill_rating,
                :drop_in_expiration_date, :credits, :subscription_credits, :scouting_credits,
                :credits_without_expiration, :subscription_skill_session_credits, :private_access,
                :birthday, :cc_cash, :source, :reserve_team, :instagram_username, :flagged,
                :is_coach, :gender, :bio, :weight, :height, :competitive_basketball_activity,
                :current_basketball_activity, :position

  includes active_subscription: :product

  filter :id
  filter :email
  filter :first_name
  filter :last_name
  filter :flagged
  filter :instagram_username
  filter :gender, as: :select, collection: User.genders
  filter :is_sem
  filter :is_referee
  filter :is_coach
  filter :skill_rating
  filter :private_access
  filter :source
  filter :created_at

  scope 'All', :all, default: true
  scope 'Members', :members
  scope 'Employees', :employees

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

  action_item :flag_user, only: [:show] do
    flagged = user.flagged
    link_to flagged ? 'Unflag User' : 'Flag User',
            flag_user_admin_user_path(id: user.id),
            method: :post,
            data: {
              confirm: "Are you sure you want to #{flagged ? 'unflag' : 'flag'} the user?"
            }
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
      f.input :gender
      f.input :instagram_username
      f.input :phone_number
      f.input :credits, label: 'Drop in credits'
      f.input :credits_without_expiration
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
      f.input :scouting_credits
      f.input :cc_cash, label: 'CC Cash'
      f.input :drop_in_expiration_date,
              as: :datepicker,
              input_html: { autocomplete: :off }
      f.input :birthday,
              as: :datepicker,
              datepicker_options: { change_year: true },
              input_html: { autocomplete: :off }
      f.input :confirmed_at, as: :hidden
      f.input :zipcode
      f.input :skill_rating
      f.input :source
      f.input :image, as: :file
      f.input :is_referee
      f.input :is_sem
      f.input :is_coach
      f.input :private_access
      f.input :reserve_team
      f.input :flagged
      f.input :bio
      f.input :weight
      f.input :height
      f.input :competitive_basketball_activity
      f.input :current_basketball_activity
      f.input :position

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
    column :gender
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
      row :gender
      row :flagged
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
      row :credits_without_expiration
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
      row :scouting_credits
      row :drop_in_expiration_date
      number_row 'CC Cash', :cc_cash, as: :currency
      row :referral_code
      row :is_referee
      row :is_sem
      row :is_coach
      row :sign_in_count
      row :zipcode
      row :free_session_state do
        user.free_session_state&.humanize
      end
      row :free_session_expiration_date
      row :skill_rating
      row :source
      row :private_access
      row :reserve_team
      row :email_confirmed, &:confirmed?
      row 'User Sessions' do
        link_to 'link to user sessions', admin_user_sessions_path(q: { user_id_eq: user.id })
      end
      row 'Payments' do
        link_to 'link to payments', admin_payments_path(q: { user_id_eq: user.id })
      end
      row 'Stripe Customer' do
        link_to 'link to stripe',
                "https://dashboard.stripe.com/#{'test/' unless Rails.env.production?}customers" \
                "/#{user.stripe_id}",
                target: '_blank',
                rel: 'noopener'
      end
      row :bio if user.employee?
      row :weight
      row :height do
        user.formatted_height
      end
      row :competitive_basketball_activity
      row :current_basketball_activity
      row :position do
        user.position&.humanize
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
        payment_methods: user.payment_methods,
        referral_users: User.where.not(id: user.id)
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

  member_action :flag_user, method: :post do
    user = User.find(params[:id])
    flagged = user.flagged

    user.flagged = !flagged
    user.save!
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

    if params[:referral_user_id].present?
      referral_user = User.find(params[:referral_user_id])
      referral_promo_code = referral_user.referral_promo_code

      unless referral_promo_code
        flash[:error] = 'The selected user does not have a referral promo code'
        return redirect_to admin_user_path(id: user.id)
      end

      referral_promo_code.validate!(user, product, true)

      PromoCodes::CreateUserPromoCode.call(
        user: user,
        promo_code: referral_promo_code,
        product: product
      )
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
    when :cancel_at_period_end
      result = Subscriptions::CancelSubscriptionAtPeriodEnd.call(
        user: user,
        subscription: user.active_subscription
      )
    when :cancel_at_next_month_period_end
      result = Subscriptions::CancelSubscriptionAtNextMonthPeriodEnd.call(
        subscription: user.active_subscription
      )
    when :cancel_immediately
      result = Subscriptions::CancelSubscription.call(
        user: user,
        subscription: user.active_subscription
      )
    when :reactivate
      result = Subscriptions::SubscriptionReactivation.call(
        user: user,
        subscription: user.active_subscription
      )
    when :remove_scheduled_cancellation
      result = Subscriptions::RemoveScheduledCancellation.call(
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
