ActiveAdmin.register PromoCode do
  permit_params :type, :code, :discount

  form do |f|
    f.inputs 'Promo Code Details' do
      f.input :type, as: :select, collection: PromoCode::TYPES
      f.input :code
      f.input :discount
    end
    f.actions
  end
end
