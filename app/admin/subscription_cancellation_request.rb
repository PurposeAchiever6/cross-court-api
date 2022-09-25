ActiveAdmin.register SubscriptionCancellationRequest do
  menu label: 'Membership Cancellation Requests', parent: 'Users', priority: 3
  actions :index, :show

  includes :user

  scope 'All', :all
  scope 'Pending', :pending, default: true
  scope 'Already Addressed', :addressed

  filter :user
  filter :created_at

  action_item :ignore, only: [:show], if: -> { subscription_cancellation_request.pending? } do
    link_to 'Ignore Cancellation Request',
            ignore_admin_subscription_cancellation_request_path(id: params[:id]),
            method: :post,
            data: { confirm: 'Are you sure you want to ignore this cancellation request?' }
  end

  index do
    selectable_column
    id_column
    tag_column :status
    column :reason do |subscription_cancellation_request|
      simple_format(subscription_cancellation_request.reason)
    end
    column :user
    column :created_at

    actions
  end

  show do
    attributes_table do
      row :status
      row :reason do |subscription_cancellation_request|
        simple_format(subscription_cancellation_request.reason)
      end
      row :user
      row :updated_at
      row :created_at
    end

    panel 'Cancel Membership' do
      render partial: 'actions',
             locals: { subscription_cancellation_request: resource, user: resource.user }
    end
  end

  member_action :ignore, method: :post do
    subscription_cancellation_request = SubscriptionCancellationRequest.find(params[:id])

    SubscriptionCancellationRequests::Ignore.call(
      subscription_cancellation_request: subscription_cancellation_request
    )

    redirect_to admin_subscription_cancellation_requests_path,
                notice: 'Membership cancellation request ignored successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_subscription_cancellation_request_path(id: params[:id])
  end

  member_action :action, method: :post do
    action_type = params[:action_type]&.to_sym
    subscription_cancellation_request = SubscriptionCancellationRequest.find(params[:id])

    case action_type
    when :cancel_at_current_period_end
      SubscriptionCancellationRequests::CancelAtCurrentPeriodEnd.call(
        subscription_cancellation_request: subscription_cancellation_request
      )
    when :cancel_at_next_month_period_end
      SubscriptionCancellationRequests::CancelAtNextMonthPeriodEnd.call(
        subscription_cancellation_request: subscription_cancellation_request
      )
    when :cancel_immediately
      SubscriptionCancellationRequests::CancelImmediately.call(
        subscription_cancellation_request: subscription_cancellation_request
      )
    else
      raise 'Unkown action type'
    end

    redirect_to admin_subscription_cancellation_requests_path,
                notice: 'Membership cancelled successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_subscription_cancellation_request_path(id: params[:id])
  end
end
