ActiveAdmin.register Product do
  permit_params :name, :credits, :price, :description, :order_number
  actions :all, except: :edit

  form do |f|
    f.inputs 'Product details' do
      f.input :name
      f.input :credits
      f.input :price
      f.input :description
      f.input :order_number
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
    end
  end

  controller do
    def create
      sku = StripeService.create_sku(sku_params)
      Product.create!(sku_params.merge(stripe_id: sku.id))
      redirect_to admin_products_path, notice: I18n.t('admin.products.created')
    end

    def destroy
      StripeService.delete_sku(resource.stripe_id)
      resource.destroy!
      redirect_to admin_products_path, notice: I18n.t('admin.products.destroyed')
    end

    private

    def sku_params
      params.require(:product).permit(:name, :credits, :price, :description, :order_number)
    end
  end
end
