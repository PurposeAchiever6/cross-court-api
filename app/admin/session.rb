ActiveAdmin.register Session do
  actions :all, except: :destroy

  permit_params :location_id, :start_time, :end_time, :recurring, :time, :level,
                session_exceptions_attributes: %i[id date _destroy]
  includes :location, :session_exceptions

  form do |f|
    f.inputs 'Session Details' do
      f.input :location
      f.input :level, include_blank: false
      f.input :start_time, as: :datepicker, datepicker_options: { min_date: Date.current }, input_html: { autocomplete: :off }
      f.input :end_time, as: :datepicker, datepicker_options: { min_date: Date.current }, input_html: { autocomplete: :off }
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
    column :level
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
      row :level
      row :start_time
      row :end_time
      row :time do |session|
        session.time.strftime(Session::TIME_FORMAT)
      end
      row :recurring do |session|
        if session.recurring?
          IceCube::Rule.from_hash(session.recurring).to_s
        else
          'Single occurrence'
        end
      end
      row :location_name
      row :created_at
      row :updated_at
    end

    panel 'Time exceptions' do
      table_for session.session_exceptions.order(date: :desc) do
        column :id
        column :date
      end
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

      panel 'Users' do
        user_sessions = resource.user_sessions.not_canceled.by_date(date).includes(:user)
        render partial: 'show_users', locals: {
          date: date,
          user_sessions: user_sessions
        }
      end

      panel 'Create User Session Manually' do
        users_for_select = User.order('LOWER(last_name)', 'LOWER(first_name)').map do |user|
          ["#{user.last_name}, #{user.first_name}", user.id]
        end

        render partial: 'create_user_session', locals: {
          date: date,
          users_for_select: users_for_select
        }
      end
    end
  end

  member_action :assign_employees, method: :put do
    referee_id = params[:referee_id]
    sem_id = params[:sem_id]
    date = params[:date]

    if referee_id.empty? && sem_id.empty?
      flash[:error] = 'You need to select a Referee or a SEM to assign'
      return redirect_to admin_session_path(id: resource.id, date: date)
    end

    resource.referee_sessions.create!(user_id: referee_id, date: date) if referee_id.present?
    resource.sem_sessions.create!(user_id: sem_id, date: date) if sem_id.present?

    redirect_to admin_root_path, notice: 'Employees assigned successfully'
  end

  member_action :create_user_session, method: :post do
    session_id = params[:id]
    user_id = params[:user_id]
    date = params[:date]
    not_charge_user_credit = params[:not_charge_user_credit] == 'true'

    if user_id.empty?
      flash[:error] = 'You need to select a player'
      return redirect_to admin_session_path(id: session_id, date: date)
    end

    user = User.find(user_id)

    ActiveRecord::Base.transaction do
      user_session = UserSession.new(
        session_id: session_id,
        user_id: user_id,
        date: date
      )

      user_session = UserSessionSlackNotification.new(user_session)
      user_session = UserSessionAutoConfirmed.new(user_session)
      user_session = UserSessionConsumeCredit.new(user_session) unless not_charge_user_credit
      user_session = UserSessionWithValidDate.new(user_session)
      user_session = UserSessionNotFull.new(user_session)
      user_session.save!

      KlaviyoService.new.event(Event::SESSION_BOOKED, user, user_session: user_session)
      SessionMailer.with(user_session_id: user_session.id).session_booked.deliver_later
    end

    redirect_to admin_session_path(id: session_id, date: date),
                notice: 'User session created successfully'
  rescue StandardError => e
    flash[:error] = e.message
    return redirect_to admin_session_path(id: session_id, date: date)
  end
end
