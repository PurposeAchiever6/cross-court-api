ActiveAdmin.register PaperTrail::Version do
  def whodunnit_for_select
    options = Hash.new { |hash, key| hash[key] = [] }

    AdminUser.select(:id, :email).order(email: :asc).each do |admin_user|
      options['Admins'] << [admin_user.email, "admin-#{admin_user.id}"]
    end

    User.select(:id, :email).order(email: :asc).each do |user|
      options['Users'] << [user.email, "user-#{user.id}"]
    end

    options
  end

  menu label: 'Events', priority: 11
  actions :index, :show

  filter :item_type
  filter :event, as: :select, collection: %w[create update destroy]
  filter :whodunnit,
         label: 'User',
         as: :select,
         collection: whodunnit_for_select

  index title: 'Events' do
    id_column
    column :by do |event|
      version_user(event)
    end
    column :at, &:created_at
    column :item_type
    column :item_id
    column :action, &:event
    actions
  end

  show do
    attributes_table do
      row :id
      row 'By' do |event|
        version_user(event)
      end
      row 'At', &:created_at
      row :item_type
      row :item_id
      row :item_link do |event|
        item = event.item
        link_to 'link to item', auto_url_for(item) if item
      end
      row :action, &:event
      row :changes do |event|
        changes_table(event, self)
      end
    end
  end
end
