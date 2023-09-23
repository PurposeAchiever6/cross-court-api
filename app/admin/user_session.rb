ActiveAdmin.register UserSession do
  menu label: 'User Sessions', parent: 'Sessions', priority: 4

  config.sort_order = ''
  actions :index, :destroy, :show
  includes :user, session: :location

  scope :all

  scope :past, group: :time
  scope :future, group: :time

  filter :user, collection: User.sorted_by_full_name.map { |user| [user.full_name, user.id] }
  filter :state, as: :select, collection: UserSession.states
  filter :first_session
  filter :is_free_session
  filter :checked_in
  filter :date

  index do
    column :id do |user_session|
      # This needs to be done like this, if not uses devise controller
      link_to user_session.id, "/admin/user_sessions/#{user_session.id}"
    end
    column :date
    column :time do |user_session|
      user_session.time.strftime(Session::TIME_FORMAT)
    end
    tag_column :state
    column :first_session
    column :free_session, &:is_free_session
    column :skill_session
    column :checked_in
    column :user
    column :location do |user_session|
      user_session.location.name
    end
    column :created_at
  end

  controller do
    def scoped_collection
      if params[:action] == 'index'
        UserSession.joins(:session).order(date: :desc, time: :desc)
      else
        super
      end
    end
  end
end
