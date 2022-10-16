ActiveAdmin.register UserSession do
  menu label: 'User Sessions', parent: 'Sessions'

  config.sort_order = ''
  actions :index, :destroy
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
    id_column
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
    column :created_at

    actions
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
