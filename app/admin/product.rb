ActiveAdmin.register Product do
  actions :all, except: :edit
  permit_params :name, :credits, :price, :description, :order_number, :image

  form do |f|
    f.inputs 'Product details' do
      f.input :name
      f.input :credits
      f.input :price
      f.input :description
      f.input :order_number
      f.input :image, as: :file
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :credits
      row :price
      row :description
      row :order_number
      row :image do |location|
        image_tag polymorphic_url(location.image) if location.image.attached?
      end
    end
  end

  controller do
    def create
      product_params = permitted_params[:product]
      sku = StripeService.create_sku(product_params)
      Product.create!(product_params.merge(stripe_id: sku.id))
      redirect_to admin_products_path, notice: I18n.t('admin.products.created')
    end

    def destroy
      StripeService.delete_sku(resource.stripe_id)
      resource.destroy!
      redirect_to admin_products_path, notice: I18n.t('admin.products.destroyed')
    end
  end
end
