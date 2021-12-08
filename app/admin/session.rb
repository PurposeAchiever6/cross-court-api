ActiveAdmin.register Session do
  actions :all, except: :destroy

  permit_params :location_id, :start_time, :end_time, :recurring, :time, :skill_level_id,
                :is_private, session_exceptions_attributes: %i[id date _destroy]
  includes :location, :session_exceptions

  form do |f|
    f.inputs 'Session Details' do
      f.input :location
      f.input :skill_level
      f.input :is_private
      f.input :start_time,
              as: :datepicker,
              datepicker_options: { min_date: Date.current },
              input_html: { autocomplete: :off }
      f.input :end_time,
              as: :datepicker,
              datepicker_options: { min_date: Date.current },
              input_html: { autocomplete: :off }
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
    column :skill_level_name
    column :time
    column :is_private

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
        if session.recurring?
          IceCube::Rule.from_hash(session.recurring).to_s
        else
          'Single occurrence'
        end
      end
      row :location_name
      row :skill_level_name
      row :is_private
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

      panel 'Arrived Users' do
        user_sessions = resource.user_sessions
                                .not_canceled
                                .by_date(date)
                                .checked_in
                                .includes(:user)
                                .order(assigned_team: :desc, updated_at: :asc)

        render partial: 'checked_in_user_sessions', locals: {
          date: date,
          user_sessions_by_team: user_sessions.group_by(&:assigned_team),
          jersey_rental_price: ENV['JERSEY_RENTAL_PRICE']
        }
      end

      panel 'Yet to Arrive Users' do
        user_sessions = resource.user_sessions
                                .joins(:user)
                                .not_canceled
                                .by_date(date)
                                .not_checked_in
                                .includes(:user)
                                .order('LOWER(users.first_name) ASC, LOWER(users.last_name) ASC')

        render partial: 'not_checked_in_user_sessions', locals: {
          date: date,
          user_sessions: user_sessions,
          jersey_rental_price: ENV['JERSEY_RENTAL_PRICE']
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

  member_action :update_user_session, method: :post do
    session_id = params[:id]
    date = params[:date]
    user_session_id = params[:user_session_id]
    checked_in = params[:checked_in] == 'true'
    jersey_rental = params[:jersey_rental] == 'true'
    assigned_team = params[:assigned_team]

    user_session = UserSession.find(user_session_id)

    jersey_rental_payment_intent_id = user_session.jersey_rental_payment_intent_id

    if user_session.jersey_rental && !jersey_rental
      result = RefundPayment.call(payment_intent_id: jersey_rental_payment_intent_id)

      if result.failure?
        flash[:error] = result.message
        return redirect_to admin_session_path(id: session_id, date: date)
      end

      jersey_rental_payment_intent_id = nil
    elsif !user_session.jersey_rental && jersey_rental
      user = user_session.user

      result = ChargeUser.call(
        user: user,
        price: ENV['JERSEY_RENTAL_PRICE'].to_i,
        description: 'Jersey rental'
      )

      if result.failure?
        flash[:error] = result.message
        return redirect_to admin_session_path(id: session_id, date: date)
      end

      jersey_rental_payment_intent_id = result.charge_payment_intent_id
    end

    user_session.update!(
      checked_in: checked_in,
      jersey_rental: jersey_rental,
      jersey_rental_payment_intent_id: jersey_rental_payment_intent_id,
      assigned_team: assigned_team
    )

    CheckInUsersJob.perform_async([user_session_id]) if checked_in

    redirect_to admin_session_path(id: session_id, date: date),
                notice: 'User session updated successfully'
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

      CreateActiveCampaignDealJob.perform_now(
        ::ActiveCampaign::Deal::Event::SESSION_BOOKED,
        user.id,
        user_session_id: user_session.id
      )
      SessionMailer.with(user_session_id: user_session.id).session_booked.deliver_later
    end

    redirect_to admin_session_path(id: session_id, date: date),
                notice: 'User session created successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_session_path(id: session_id, date: date)
  end
end
