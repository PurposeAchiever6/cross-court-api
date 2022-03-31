ActiveAdmin.register SubscriptionFeedback do
  menu label: 'Members Cancellation', parent: 'Feedbacks'
  actions :index, :show, :destroy
  includes :user

  index do
    selectable_column
    id_column
    column :feedback do |subscription_feedback|
      simple_format(subscription_feedback.feedback)
    end
    column :user

    actions
  end

  show do
    attributes_table do
      row :feedback do |subscription_feedback|
        simple_format(subscription_feedback.feedback)
      end
      row :user
    end
  end
end
