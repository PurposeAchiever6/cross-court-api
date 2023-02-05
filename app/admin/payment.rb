ActiveAdmin.register Payment do
  menu parent: 'Users', priority: 2
  actions :index, :show

  includes :user

  scope 'All', :all, default: true
  scope 'Successful', :success
  scope 'Rejected', :error
  scope 'Refunded', :refunded
  scope 'Partially Refunded', :partially_refunded

  filter :user
  filter :description
  filter :amount
  filter :amount_refunded
  filter :discount
  filter :cc_cash
  filter :created_at

  index do
    id_column
    column :user
    tag_column :status
    column :description
    number_column :total_amount, as: :currency
    number_column :discount, as: :currency
    number_column :cc_cash, as: :currency
    number_column :charged, :amount, as: :currency
    number_column :refunded, :amount_refunded, as: :currency
    column :card do |payment|
      payment.amount.positive? ? "****#{payment.last_4}" : 'N/A'
    end
    column 'Stripe Payment' do |payment|
      link_to 'Link to Stripe',
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
      tag_row :status
      row :description
      number_row :total_amount, as: :currency
      number_row :discount, as: :currency
      number_row :cc_cash, as: :currency
      number_row :charged, :amount, as: :currency
      number_row :refunded, :amount_refunded, as: :currency
      row :card do
        payment.amount.positive? ? "****#{payment.last_4}" : 'N/A'
      end
      row :error_message
      row 'Stripe Payment' do
        link_to 'Link to Stripe',
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
