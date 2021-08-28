ActiveAdmin.register PromoCode do
  actions :index, :show, :create, :new
  config.batch_actions = false
  permit_params :type, :code, :discount, :expiration_date, :product_id

  collection = PromoCode::TYPES.map { |type| [type.underscore.humanize, type] }

  index do
    id_column
    column :discount
    column :code
    column :created_at
    column :expiration_date
    column :product
    column :type do |promo_code|
      promo_code.type.underscore.humanize
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :discount
      row :code
      row :created_at
      row :expiration_date
      row :product
      row :type do |promo_code|
        promo_code.type.underscore.humanize
      end
      row :stripe_coupon_id
      row :stripe_promo_code_id
    end
  end

  form do |f|
    f.inputs 'Promo Code Details' do
      f.input :product
      f.input :type, as: :select, collection: collection
      f.input :code
      f.input :discount
      f.input :expiration_date, as: :datepicker, datepicker_options: { min_date: Date.current }, input_html: { autocomplete: :off }
    end
    f.actions
  end

  controller do
    def create
      promo_code_params = permitted_params[:promo_code]
      product_id = promo_code_params[:product_id]
      product = Product.find(product_id) if product_id.present?

      if product&.recurring?
        @resource = PromoCode.new(promo_code_params)

        if @resource.valid?
          coupon_id = StripeService.create_coupon(promo_code_params, product).id
          promo_code_id = StripeService.create_promotion_code(coupon_id, promo_code_params).id

          @resource.stripe_coupon_id = coupon_id
          @resource.stripe_promo_code_id = promo_code_id

          @resource.save!

          redirect_to admin_promo_codes_path,
                      notice: I18n.t('admin.promo_codes.created', type: promo_code_params[:type].underscore.humanize)
        else
          render action: 'new'
        end
      else
        super
      end
    end

    def destroy
      promo_code = PromoCode.find(permitted_params[:id])
      product = promo_code.product

      if product&.recurring?
        StripeService.update_promotion_code(promo_code.stripe_promo_code_id, active: false)
        StripeService.delete_coupon(promo_code.stripe_coupon_id)

        resource.destroy!

        redirect_to admin_promo_codes_path,
                    notice: I18n.t('admin.promo_codes.destroyed', type: promo_code.type.underscore.humanize)
      else
        super
      end
    end
  end
end
