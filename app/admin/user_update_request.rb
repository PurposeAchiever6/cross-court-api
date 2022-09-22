ActiveAdmin.register UserUpdateRequest do
  menu label: 'Update Requests', parent: 'Users', priority: 2
  actions :index, :show, :destroy

  includes :user

  scope 'All', :all
  scope 'Pending', :pending, default: true
  scope 'Approvals', :approved
  scope 'Rejects', :rejected

  filter :user
  filter :created_at

  action_item :approve, only: :show, priority: 0, if: -> { user_update_request.pending? } do
    link_to 'Approve',
            approve_admin_user_update_request_path(user_update_request.id),
            method: :post
  end

  action_item :reject, only: :show, priority: 1, if: -> { user_update_request.pending? } do
    link_to 'Reject',
            reject_admin_user_update_request_path(user_update_request.id),
            method: :post
  end

  index do
    id_column
    column :user
    column :requested_changes do |user_update_request|
      safe_join(user_update_request.readable_requested_attributes, '<br>'.html_safe)
    end
    column :reason
    tag_column :status
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :user
      row :requested_changes do |user_update_request|
        safe_join(user_update_request.readable_requested_attributes, '<br>'.html_safe)
      end
      row :reason
      row :status
      row :requested_attributes
      row :updated_at
      row :created_at
    end
  end

  member_action :approve, method: :post do
    user_update_request = UserUpdateRequest.find(params[:id])

    UserUpdateRequests::Approve.call(user_update_request: user_update_request)

    redirect_to admin_user_update_requests_path, notice: 'Request approved successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_user_update_request_path(id: params[:id])
  end

  member_action :reject, method: :post do
    user_update_request = UserUpdateRequest.find(params[:id])

    UserUpdateRequests::Reject.call(user_update_request: user_update_request)

    redirect_to admin_user_update_requests_path, notice: 'Request rejected successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_user_update_request_path(id: params[:id])
  end
end
