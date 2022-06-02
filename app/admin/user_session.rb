ActiveAdmin.register UserSession do
  menu label: 'User Sessions', parent: 'Sessions'

  actions :index, :destroy
  includes :user, session: :location

  filter :user, collection: User.sorted_by_full_name.map { |user| [user.full_name, user.id] }
  filter :state, as: :select, collection: UserSession.states
  filter :first_session
  filter :is_free_session
  filter :checked_in

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
    column :user
    column :location do |user_session|
      user_session.location.name
    end

    actions
  end
end
