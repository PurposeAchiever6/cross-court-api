ActiveAdmin.register SubscriptionCancellationRequest do
  menu label: 'Membership Cancellation Requests', parent: 'Users', priority: 3
  actions :index, :show, :destroy
  includes :user

  index do
    selectable_column
    id_column
    column :reason do |subscription_cancellation_request|
      simple_format(subscription_cancellation_request.reason)
    end
    column :user

    actions
  end

  show do
    attributes_table do
      row :reason do |subscription_cancellation_request|
        simple_format(subscription_cancellation_request.reason)
      end
      row :user
    end
  end
end
