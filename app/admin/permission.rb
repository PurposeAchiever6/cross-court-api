require_relative '../../db/seeds/roles_and_permissions'

ActiveAdmin.register Permission do
  menu parent: 'Roles and Permissions', priority: 2

  actions :index, :destroy

  config.sort_order = 'name_asc'

  filter :name
  filter :roles

  action_item :seeds, only: [:index] do
    link_to 'Run Permissions Seeds',
            seeds_admin_permissions_path,
            method: :post,
            data: { confirm: 'Are you sure you want to run the permissions seeds?' }
  end

  index do
    id_column
    column :name
    actions
  end

  collection_action :seeds, method: :post do
    Seeds::RolesAndPermissions.run
    flash[:notice] = 'Permissions seeds ran successfully'
  rescue StandardError => e
    flash[:error] = e.message
  ensure
    redirect_to admin_permissions_path
  end
end
