ActiveAdmin.register Product do
  menu label: 'Products', parent: 'Products'

  permit_params :name, :credits, :skill_session_credits, :price, :price_for_members, :order_number,
                :image, :label, :referral_cc_cash, :product_type, :max_rollover_credits,
                :price_for_first_timers_no_free_session, :available_for, :season_pass, :scouting,
                :free_pauses_per_year, :highlighted, :highlights, :free_jersey_rental,
                :free_towel_rental, :description, :waitlist_priority, :promo_code_id,
                :no_booking_charge_feature, :no_booking_charge_feature_hours, :trial,
                :no_booking_charge_feature_priority, :credits_expiration_days

  filter :name
  filter :product_type
  filter :price

  scope :all, default: true
  scope 'Deleted', :only_deleted

  includes :promo_code

  action_item :new_price, only: :show, if: -> { product.recurring? } do
    link_to 'Update Pricing',
            new_price_admin_product_path(product.id)
  end

  index do
    selectable_column
    id_column
    column :name
    column :credits do |product|
      product.unlimited? ? 'Unlimited' : product.credits
    end
    column :skill_session_credits do |product|
      if product.recurring?
        product.skill_session_unlimited? ? 'Unlimited' : product.skill_session_credits
      else
        'N/A'
      end
    end
    column :max_rollover_credits do |product|
      product.unlimited? || product.one_time? ? 'N/A' : product.max_rollover_credits
    end
    number_column :price, as: :currency
    number_column :price_for_members, as: :currency
    number_column :price_for_first_timers_no_free_session, as: :currency
    column :free_pauses_per_year do |product|
      product.recurring? ? product.free_pauses_per_year : 'N/A'
    end
    number_column 'Referral CC Cash', :referral_cc_cash, as: :currency
    column :label
    column :order_number
    column :product_type do |product|
      product.product_type.humanize
    end
    column :promo_code
    column :no_booking_charge_feature do |product|
      product.recurring? ? product.no_booking_charge_feature : 'N/A'
    end
    column :season_pass
    column :scouting
    column :trial
    column :available_for do |product|
      product.available_for.humanize
    end
    column :memberships_count do |product|
      product.recurring? ? product.memberships_count : 'N/A'
    end
    column :credits_expiration_days do |product|
      product.recurring? ? 'N/A' : product.credits_expiration_days
    end
    if params['scope'] == 'deleted'
      column do |product|
        link_to 'Recover', recover_admin_product_path(product), method: :post
      end
    else
      actions
    end
  end

  form do |f|
    persisted = resource.persisted?

    unlimited_sessions_checkbox = []
    unlimited_sessions_checkbox << label_tag('Unlimited Sessions')
    unlimited_sessions_checkbox << check_box_tag(
      :unlimited_credits,
      '1',
      resource.unlimited?,
      id: 'product-sessions-unlimited'
    )

    unlimited_skill_sessions_checkbox = []
    unlimited_skill_sessions_checkbox << label_tag('Unlimited Skill Sessions')
    unlimited_skill_sessions_checkbox << check_box_tag(
      :unlimited_skill_session_credits,
      '1',
      resource.skill_session_unlimited?,
      id: 'product-skill-sessions-unlimited'
    )

    f.inputs 'Product details' do
      f.input :product_type, input_html: { disabled: persisted }
      f.input :available_for
      f.input :season_pass
      f.input :scouting
      f.input :trial
      f.input :highlighted
      f.input :highlights
      f.input :free_jersey_rental
      f.input :free_towel_rental
      f.input :no_booking_charge_feature,
              wrapper_html: { class: 'mb-4' },
              label: 'Members can book with no cost sessions with less than ' \
                     "#{Session::RESERVATIONS_LIMIT_FOR_NO_CHARGE + 1} sign ups and " \
                     '"no booking charge feature hours" hours before session starts'
      f.input :no_booking_charge_feature_hours
      f.input :no_booking_charge_feature_priority,
              hint: 'This will be used for the Compare Memberships Table on the frontend'
      f.input :name
      f.li unlimited_sessions_checkbox, id: 'product-sessions-unlimited-container'
      f.input :credits
      f.input :credits_expiration_days
      f.input :max_rollover_credits,
              hint: 'Max amount of rolled-over credits. If not set, ' \
                    'all pack credits will be rolled over'
      f.li unlimited_skill_sessions_checkbox, id: 'product-skill-sessions-unlimited-container'
      f.input :skill_session_credits
      f.input :price, input_html: { disabled: persisted && resource.recurring? }
      f.input :price_for_members
      f.input :price_for_first_timers_no_free_session
      f.input :free_pauses_per_year
      f.input :waitlist_priority
      f.input :referral_cc_cash, label: 'Referral CC cash'
      f.input :label
      f.input :order_number

      if persisted
        f.input :promo_code,
                collection: PromoCode.general.for_product(product).order(:code),
                hint: 'Promo code used for the signup onboarding flow'
      end

      f.input :image, as: :file
      f.input :description
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :credits do |product|
        product.unlimited? ? 'Unlimited' : product.credits
      end
      row :credits_expiration_days do |product|
        product.recurring? ? 'N/A' : product.credits_expiration_days
      end
      if resource.recurring?
        row :skill_session_credits do |product|
          product.skill_session_unlimited? ? 'Unlimited' : product.skill_session_credits
        end
        row :max_rollover_credits do
          product.unlimited? ? 'N/A' : product.max_rollover_credits
        end
      end
      number_row :price, as: :currency
      number_row :price_for_members, as: :currency if resource.one_time?
      number_row :price_for_first_timers_no_free_session, as: :currency if resource.one_time?
      row :free_pauses_per_year do |product|
        product.recurring? ? product.free_pauses_per_year : 'N/A'
      end
      number_row :referral_cc_cash, as: :currency if resource.recurring?
      row :product_type do |product|
        product.product_type.humanize
      end
      row :available_for do |product|
        product.available_for.humanize
      end
      row :season_pass
      row :scouting
      row :trial
      row :highlighted
      row :highlights
      row :free_jersey_rental
      row :free_towel_rental
      row :no_booking_charge_feature do |product|
        product.recurring? ? product.no_booking_charge_feature : 'N/A'
      end
      row :no_booking_charge_feature_hours do |product|
        product.recurring? ? product.no_booking_charge_feature_hours : 'N/A'
      end
      row :no_booking_charge_feature_priority do |product|
        product.recurring? ? product.no_booking_charge_feature_priority : 'N/A'
      end
      row :waitlist_priority
      row :label
      row :order_number
      row :memberships_count do |product|
        product.recurring? ? product.memberships_count : 'N/A'
      end
      row :promo_code do |product|
        product.recurring? ? product.promo_code : 'N/A'
      end
      row :image do |product|
        image_tag polymorphic_url(product.image), class: 'max-w-200' if product.image.attached?
      end
      row 'History' do |product|
        link_to 'Link to History', history_admin_product_path(product.id)
      end
      row :description
      row :created_at
      row :updated_at
    end
  end

  controller do
    def create
      product_params = permitted_params[:product]

      @resource = Product.new(product_params)

      if @resource.valid?
        stripe_product_id = StripeService.create_product(product_params).id
        stripe_price_id = StripeService.create_price(
          product_params.merge(stripe_product_id:)
        ).id

        @resource.stripe_product_id = stripe_product_id
        @resource.stripe_price_id = stripe_price_id
        @resource.save!

        redirect_to admin_products_path, notice: I18n.t('admin.products.created')
      else
        render :new
      end
    rescue StandardError => e
      flash[:error] = e.message
      render :new
    end

    def destroy
      StripeService.update_price(resource.stripe_price_id, active: false)
      StripeService.update_product(resource.stripe_product_id, active: false)
      resource.destroy!

      redirect_to admin_products_path, notice: I18n.t('admin.products.destroyed')
    end
  end

  member_action :recover, method: :post do
    product = Product.with_deleted.find(params[:id])

    StripeService.update_price(product.stripe_price_id, active: true)
    product.recover

    redirect_to admin_products_path, notice: I18n.t('admin.products.recover')
  end

  member_action :new_price do
    @product = Product.find(params[:id])
    @subscriptions_count = @product.subscriptions.active_or_paused.count
  end

  member_action :update_price, method: :post do
    product = Product.find(params[:id])
    new_price = params[:new_price]
    update_existing_subscriptions = params[:update_existing_subscriptions] == '1'
    error_msg = nil

    error_msg = 'Product must be of the type recurring' if product.one_time?
    error_msg = 'New price can\'t be empty' if new_price.blank?
    if new_price.to_d == product.price.to_d
      error_msg = 'New price is the same as the current product price'
    end

    if error_msg
      flash[:error] = error_msg
      return redirect_to new_price_admin_product_path(params[:id])
    end

    product.update_recurring_price(new_price, update_existing_subscriptions:)

    redirect_to admin_product_path(params[:id]), notice: I18n.t('admin.products.update_price')
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_product_path(params[:id])
  end

  member_action :history do
    versions = Product.find(params[:id]).versions.reorder(created_at: :desc).limit(30)
    render 'admin/shared/history', locals: { versions: }
  end
end
