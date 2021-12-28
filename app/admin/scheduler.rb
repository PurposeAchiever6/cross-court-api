ActiveAdmin.register_page 'Scheduler' do
  menu priority: 1, label: 'Scheduler'

  content do
    location = Location.find_by(id: params[:location]) || Location.first
    start_date_param = params[:start_date]
    start_date = start_date_param ? Date.parse(start_date_param) : Time.current
    from = start_date.beginning_of_month.beginning_of_week
    to = start_date.end_of_month.end_of_week

    sessions = Session.includes(:session_exceptions, :referee_sessions, :sem_sessions)
                      .by_location(location)
                      .for_range(from, to).flat_map { |session| session.calendar_events(from, to) }

    Time.use_zone(location.time_zone) do
      render partial: 'calendar', locals: {
        sessions: SessionDecorator.decorate_collection(sessions),
        locations: Location.all,
        selected_location: location.id
      }
    end
  end
end
