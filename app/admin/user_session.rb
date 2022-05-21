ActiveAdmin.register UserSession do
  menu label: 'User Sessions', parent: 'Sessions'

  actions :index, :destroy
  includes :user, session: :location

  index do
    selectable_column
    column :date
    column :time do |user_session|
      user_session.time.strftime(Session::TIME_FORMAT)
    end
    tag_column :state
    column :first_session
    column :free_session, &:is_free_session
    column :checked_in
    column :user_name do |user_session|
      user_session.user.full_name
    end
    column :location do |user_session|
      user_session.location.name
    end

    actions
  end

  filter :user, collection: proc {
    User.order(:first_name, :last_name).all.map { |user| [user.full_name, user.id] }
  }
end
