ActiveAdmin.register SubscriptionPause do
  menu label: 'Subscription Pauses', parent: 'Users', priority: 5
  actions :index, :show
  includes subscription: :user

  filter :reason

  index do
    id_column
    column :user do |subscription_pause|
      subscription_pause.subscription&.user
    end
    column :status
    column :paused_from
    column :paused_until
    column :reason
    column :updated_at
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :user do
        subscription_pause.subscription&.user
      end
      row :status
      row :paused_from
      row :paused_until
      row :reason
      row :updated_at
      row :created_at
    end
  end
end
