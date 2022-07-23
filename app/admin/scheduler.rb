ActiveAdmin.register_page 'Scheduler' do
  menu label: 'Scheduler', priority: 1

  content do
    location = Location.find_by(id: params[:location]) || Location.first
    start_date_param = params[:start_date]
    start_date = start_date_param ? Date.parse(start_date_param) : Time.current
    from = start_date.beginning_of_month.beginning_of_week
    to = start_date.end_of_month.end_of_week

    sessions = Session.includes(:session_exceptions, :location, :skill_level)
                      .by_location(location)
                      .for_range(from, to).flat_map { |session| session.calendar_events(from, to) }

    Time.use_zone(location.time_zone) do
      render partial: 'calendar', locals: {
        sessions: SessionDecorator.decorate_collection(sessions),
        locations: Location.all,
        selected_location: location.id
      }
    end

    div do
      text_node 'References:'
      br
      text_node 'EM - Referee or SEM not assigned'
      br
      text_node 'OC - Open Club'
      br
      text_node 'CS - Coming Soon'
      br
      text_node 'P - Private session'
      br
      text_node 'WO - Women Only'
      br
      text_node 'SS - Skill Session'
      br
      text_node 'AS - All skill levels allowed'
    end
  end
end
