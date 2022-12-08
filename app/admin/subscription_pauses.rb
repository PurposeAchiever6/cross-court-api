ActiveAdmin.register SubscriptionPause do
  menu label: 'Membership Pauses', parent: 'Users', priority: 5
  actions :index, :show
  includes subscription: :user

  filter :reason

  index do
    id_column
    column :user do |subscription_pause|
      subscription_pause.subscription&.user
    end
    column :status do |subscription_pause|
      subscription_pause.status&.humanize
    end
    column :paused_from
    column :paused_until
    column :reason do |subscription_pause|
      subscription_pause.reason&.humanize
    end
    column :updated_at
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :user do
        subscription_pause.subscription&.user
      end
      row :status do
        subscription_pause.status&.humanize
      end
      row :paused_from
      row :paused_until
      row :reason do
        subscription_pause.reason&.humanize
      end
      row :updated_at
      row :created_at
    end
  end
end
