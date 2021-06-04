ActiveAdmin.register Product do
  permit_params :name, :credits, :price, :order_number, :image, :label, :product_type

  index do
    selectable_column
    id_column
    column :name
    column :credits do |product|
      product.unlimited? ? 'Unlimited' : product.credits
    end
    column :price
    column :label
    column :order_number
    column :product_type

    actions
  end

  form do |f|
    checkbox = []
    checkbox << label_tag('unlimited')
    checkbox << check_box_tag('unlimited', '1', resource.persisted? && resource.unlimited?, disabled: resource.persisted?, id: 'product-unlimited')

    f.inputs 'Product details' do
      f.input :name, input_html: { disabled: resource.persisted? }
      f.input :credits, input_html: { disabled: resource.persisted? }
      f.li checkbox
      f.input :price, input_html: { disabled: resource.persisted? }
      f.input :label
      f.input :order_number
      f.input :image, as: :file
      f.input :product_type
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
      row :price
      row :label
      row :order_number
      row :image do |product|
        image_tag polymorphic_url(product.image), class: 'mw-200px' if product.image.attached?
      end
    end
  end

  controller do
    def create
      product_params = permitted_params[:product]
      stripe_price_id = StripeService.create_price(product_params).id
      Product.create!(product_params.merge(stripe_price_id: stripe_price_id))
      redirect_to admin_products_path, notice: I18n.t('admin.products.created')
    end

    def destroy
      stripe_price_id = resource.stripe_price_id
      StripeService.update_price(stripe_price_id, active: false) if stripe_price_id
      resource.destroy!
      redirect_to admin_products_path, notice: I18n.t('admin.products.destroyed')
    end
  end
end
