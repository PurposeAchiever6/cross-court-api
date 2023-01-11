ActiveAdmin.register Product do
  menu label: 'Products', parent: 'Products'

  permit_params :name, :credits, :skill_session_credits, :price, :price_for_members, :order_number,
                :image, :label, :referral_cc_cash, :product_type, :max_rollover_credits,
                :price_for_first_timers_no_free_session, :available_for, :season_pass, :scouting

  filter :name
  filter :product_type
  filter :price

  scope :all, default: true
  scope 'Deleted', :only_deleted

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
    number_column 'Referral CC Cash', :referral_cc_cash, as: :currency
    column :label
    column :order_number
    column :product_type do |product|
      product.product_type.humanize
    end
    tag_column :season_pass
    tag_column :scouting
    column :available_for do |product|
      product.available_for.humanize
    end
    column :memberships_count do |product|
      product.recurring? ? product.memberships_count : 'N/A'
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
      'unlimited',
      '1',
      resource.unlimited?,
      disabled: persisted,
      id: 'product-sessions-unlimited'
    )

    unlimited_skill_sessions_checkbox = []
    unlimited_skill_sessions_checkbox << label_tag('Unlimited Skill Sessions')
    unlimited_skill_sessions_checkbox << check_box_tag(
      'unlimited',
      '1',
      resource.skill_session_unlimited?,
      disabled: persisted,
      id: 'product-skill-sessions-unlimited'
    )

    f.inputs 'Product details' do
      f.input :product_type, input_html: { disabled: persisted }
      f.input :available_for
      f.input :season_pass
      f.input :scouting
      f.input :name
      f.li unlimited_sessions_checkbox, id: 'product-sessions-unlimited-container'
      f.input :credits
      f.li unlimited_skill_sessions_checkbox, id: 'product-skill-sessions-unlimited-container'
      f.input :skill_session_credits
      f.input :max_rollover_credits,
              input_html: { disabled: resource.unlimited? },
              hint: 'Max amount of rolled-over credits. If not set, ' \
                    'all pack credits will be rolled over'
      f.input :price, input_html: { disabled: persisted && resource.recurring? }
      f.input :price_for_members
      f.input :price_for_first_timers_no_free_session
      f.input :referral_cc_cash, label: 'Referral CC cash'
      f.input :label
      f.input :order_number
      f.input :image, as: :file
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
      number_row :referral_cc_cash, as: :currency if resource.recurring?
      row :product_type do |product|
        product.product_type.humanize
      end
      row :available_for do |product|
        product.available_for.humanize
      end
      row :season_pass
      row :scouting
      row :label
      row :order_number
      row :memberships_count do |product|
        product.recurring? ? product.memberships_count : 'N/A'
      end
      row :image do |product|
        image_tag polymorphic_url(product.image), class: 'max-w-200' if product.image.attached?
      end
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
end
