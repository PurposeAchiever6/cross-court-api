ActiveAdmin.register Session do
  actions :all, except: :destroy

  permit_params :location_id, :start_time, :end_time, :recurring, :time,
                session_exceptions_attributes: %i[id date _destroy]
  includes :location, :session_exceptions

  form do |f|
    f.inputs 'Session Details' do
      f.input :location

      f.input :start_time, as: :datepicker, datepicker_options: { min_date: Date.current }
      f.input :end_time, as: :datepicker, datepicker_options: { min_date: Date.current }
      f.input :time
      f.select_recurring :recurring, nil, allow_blank: true
      f.has_many :session_exceptions, allow_destroy: true do |p|
        p.input :date, as: :datepicker
      end
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :location_name
    column :time

    actions
  end

  show title: proc { |session|
                date = params[:date]
                if date.present?
                  "Session for #{date} at #{session.time.strftime(Session::TIME_FORMAT)}"
                else
                  "Session #{session.id}"
                end
              } do
    attributes_table do
      row :id
      row :start_time
      row :end_time
      row :time do |session|
        session.time.strftime(Session::TIME_FORMAT)
      end
      row :recurring do |session|
        IceCube::Rule.from_hash(session.recurring).to_s
      end
      row :location_name
      row :created_at
      row :updated_at
    end

    date = params[:date]
    if date.present?
      panel 'Employees' do
        referee = resource.referee(date)
        sem = resource.sem(date)
        if params[:edit_employees].present? || referee.nil? || sem.nil?
          render partial: 'edit_employees', locals: {
            selected_session: resource,
            date: date,
            referee: referee,
            sem: sem
          }
        else
          render partial: 'show_employees', locals: {
            date: date,
            referee: referee,
            sem: sem
          }
        end
      end
    end

    panel 'Time exceptions' do
      table_for session.session_exceptions.order(date: :desc) do
        column :id
        column :date
      end
    end
  end

  member_action :assign_employees, method: :put do
    referee_id = params[:referee_id]
    sem_id = params[:sem_id]
    date = params[:date]

    if referee_id.nil? && sem_id.nil?
      redirect_to admin_session_path(id: resource.id, date: date),
                  notice: 'You need to select a Referee or a SEM to assign'
    end

    resource.referee_sessions.create!(user_id: referee_id, date: date) if referee_id.present?
    resource.sem_sessions.create!(user_id: sem_id, date: date) if sem_id.present?

    redirect_to admin_root_path, notice: 'Employees assigned successfully'
  end
end
