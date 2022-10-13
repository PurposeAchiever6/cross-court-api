ActiveAdmin.register Payment do
  menu parent: 'Users', priority: 2
  actions :index, :show

  includes :user

  scope 'All', :all, default: true
  scope 'Successful', :success
  scope 'Rejected', :error

  filter :user
  filter :description
  filter :amount
  filter :discount
  filter :cc_cash
  filter :created_at

  index do
    id_column
    column :user
    tag_column :status
    column :description
    column :amount
    column :discount
    column :cc_cash
    column :card do |payment|
      "****#{payment.last_4}"
    end
    column 'Stripe Payment' do |payment|
      link_to 'link to stripe',
              "https://dashboard.stripe.com/#{'test/' unless Rails.env.production?}payments" \
              "/#{payment.stripe_id}",
              target: '_blank',
              rel: 'noopener'
    end
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :user
      row :status
      row :description
      row :amount
      row :discount
      row :cc_cash
      row :card do
        "****#{payment.last_4}"
      end
      row :error_message
      row 'Stripe Payment' do
        link_to 'link to stripe',
                "https://dashboard.stripe.com/#{'test/' unless Rails.env.production?}payments" \
                "/#{payment.stripe_id}",
                target: '_blank',
                rel: 'noopener'
      end
      row :updated_at
      row :created_at
    end
  end
end
