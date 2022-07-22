ActiveAdmin.register UserPromoCode do
  menu label: 'Used Promo Codes', parent: 'Products'
  actions :index, :show

  filter :user
  filter :promo_code
  filter :created_at
  filter :times_used

  index do
    selectable_column
    id_column
    column :user
    column :created_at
    actions
  end
end
