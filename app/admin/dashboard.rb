ActiveAdmin.register_page 'Dashboard' do
  menu priority: 1, label: proc { I18n.t('active_admin.dashboard') }

  content do
    start_date_param = params[:start_date]
    start_date = start_date_param ? Date.parse(start_date_param) : Time.current
    from = start_date.beginning_of_month.beginning_of_week
    to = start_date.end_of_month.end_of_week
    sessions = Session.by_location(params[:location]).for_range(from, to).flat_map do |meeting|
      meeting.calendar_events(from, to)
    end
    render partial: 'calendar', locals: {
      sessions: sessions,
      locations: Location.all,
      selected_location: params[:location]
    }
  end
end
