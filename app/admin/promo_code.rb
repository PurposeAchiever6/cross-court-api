ActiveAdmin.register PromoCode do
  menu label: 'Promo Codes', parent: 'Products'

  config.batch_actions = false
  permit_params :type, :code, :discount, :expiration_date, :duration,
                :duration_in_months, :max_redemptions, :max_redemptions_by_user,
                :user_max_checked_in_sessions, :only_for_new_members, product_ids: []

  includes :products

  scope 'Generals', :general, default: true
  scope 'Users Referrals', :referral
  scope 'CC Cash Applied to Memberships', :cc_cash

  index do
    id_column
    column :discount
    column :code
    column :created_at
    column :expiration_date
    column :products
    column :duration
    column :duration_in_months
    column :type do |promo_code|
      promo_code.type.underscore.humanize
    end
    column :times_used
    column :max_redemptions
    column :max_redemptions_by_user
    column :user_max_checked_in_sessions
    column :only_for_new_members

    actions
  end

  show do
    attributes_table do
      row :id
      row :discount
      row :code
      row :created_at
      row :expiration_date
      row :products
      row :type do |promo_code|
        promo_code.type.underscore.humanize
      end
      row :duration
      row :duration_in_months
      row :times_used
      row :max_redemptions
      row :max_redemptions_by_user
      row :user_max_checked_in_sessions
      row :only_for_new_members
      row :stripe_coupon_id
      row :stripe_promo_code_id
    end
  end

  form data: { recurring_product_ids: Product.recurring.ids } do |f|
    disabled = !f.object.new_record?

    products_disabled = disabled ? Product.ids : []

    f.inputs 'Promo Code Details' do
      f.input :products,
              as: :check_boxes,
              disabled: products_disabled,
              include_blank: false,
              hidden_fields: true
      f.input :type,
              as: :select,
              collection: PromoCode::TYPES.map { |type| [type.underscore.humanize, type] },
              input_html: { disabled: }
      f.input :code, input_html: { disabled: }
      f.input :discount, input_html: { disabled: }
      f.input :only_for_new_members,
              as: :select,
              label: 'Only valid for new members',
              hint: 'If true, this promo code will only be valid for those ' \
                    'users that have never been a Crosscourt member before.'
      f.input :max_redemptions,
              hint: 'Number of times the code can be used across all users before it’s no longer ' \
                    'valid. If not set, it can be used with no restrictions.'
      f.input :max_redemptions_by_user,
              hint: 'Number of times the code can be used per user before it’s no longer ' \
                    'valid. If not set, the same user can use it the times he wants.'
      f.input :user_max_checked_in_sessions,
              hint: 'Number of sessions attended by user before it’s not valid. If not set, ' \
                    'means no restriction. I.e, if set to 0 it means the ' \
                    'promo code is only valid for users who have not played any session.'
      f.input :expiration_date,
              as: :datepicker,
              datepicker_options: { min_date: Date.current },
              input_html: { autocomplete: :off, disabled: }
      f.input :duration,
              as: :select,
              collection: PromoCode.durations.keys.to_a.excluding('once'),
              input_html: { disabled: },
              hint: 'Only valid for recurring products.'
      f.input :duration_in_months, input_html: { disabled: }
    end
    f.actions
  end

  controller do
    def create
      promo_code_params = permitted_params[:promo_code]
      product_ids = promo_code_params[:product_ids]
      products = Product.where(id: product_ids)

      recurring_products = products.filter(&:recurring?)

      if recurring_products.any?
        @resource = PromoCode.new(promo_code_params)

        if @resource.valid?
          coupon_id = StripeService.create_coupon(promo_code_params, recurring_products).id
          promo_code_id = StripeService.create_promotion_code(coupon_id, promo_code_params).id

          @resource.stripe_coupon_id = coupon_id
          @resource.stripe_promo_code_id = promo_code_id

          @resource.save!

          redirect_to admin_promo_codes_path,
                      notice: I18n.t('admin.promo_codes.created',
                                     type: promo_code_params[:type].underscore.humanize)
        else
          render action: 'new'
        end
      else
        super
      end
    rescue Stripe::StripeError => e
      flash.now[:error] = e.message
      render :new
    end

    def destroy
      promo_code = PromoCode.find(permitted_params[:id])
      stripe_coupon_id = promo_code.stripe_coupon_id
      stripe_promo_code_id = promo_code.stripe_promo_code_id

      if stripe_coupon_id && stripe_promo_code_id
        StripeService.update_promotion_code(stripe_promo_code_id, active: false)
        StripeService.delete_coupon(stripe_coupon_id)

        resource.destroy!

        redirect_to admin_promo_codes_path,
                    notice: I18n.t('admin.promo_codes.destroyed',
                                   type: promo_code.type.underscore.humanize)
      else
        super
      end
    rescue Stripe::StripeError => e
      flash[:error] = e.message
      redirect_to admin_promo_codes_path
    end
  end
end
