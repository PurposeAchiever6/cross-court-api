ActiveAdmin.register PromoCode do
  permit_params :type, :code, :discount, :expiration_date

  form do |f|
    f.inputs 'Promo Code Details' do
      f.input :type, as: :select, collection: PromoCode::TYPES
      f.input :code
      f.input :discount
      f.input :expiration_date, as: :datepicker, datepicker_options: { min_date: Date.current }
    end
    f.actions
  end
end
