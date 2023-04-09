ActiveAdmin.register Session do
  menu label: 'Sessions', parent: 'Sessions', priority: 2

  permit_params :location_id, :start_time, :end_time, :recurring, :time, :skill_level_id,
                :is_private, :is_open_club, :coming_soon, :women_only, :skill_session,
                :members_only, :duration_minutes, :max_capacity, :max_first_timers,
                :theme_title, :theme_subheading, :theme_description,
                :all_skill_levels_allowed, :allow_back_to_back_reservations, :cc_cash_earned,
                :default_referee_id, :default_sem_id, :default_coach_id, :guests_allowed,
                :guests_allowed_per_user, :cost_credits,
                product_ids: [],
                session_exceptions_attributes: %i[id date _destroy],
                shooting_machines_attributes: %i[id start_time end_time price _destroy]

  includes :location, :session_exceptions, :skill_level

  filter :location
  filter :skill_level
  filter :start_time
  filter :end_time
  filter :is_private
  filter :is_open_club
  filter :coming_soon
  filter :women_only
  filter :skill_session
  filter :members_only
  filter :guests_allowed
  filter :guests_allowed_per_user

  scope :all, default: true
  scope 'Deleted', :only_deleted

  action_item :cancel, only: :show, priority: 0, if: -> { params[:date].present? } do
    link_to 'Cancel Session',
            cancel_admin_session_path(session.id, date: params[:date]),
            method: :post,
            data: { disable_with: 'Loading...',
                    confirm: 'Are you sure you want to cancel this session? This will refund ' \
                             'all signed up users their credits back, and notify them via SMS. ' \
                             'It will also make the session unavailable for this date.' }
  end

  action_item :cancel, only: :show, priority: 1, if: -> { params[:date].present? } do
    link_to 'Cancel Session With Open Club',
            cancel_admin_session_path(session.id, date: params[:date], with_open_club: true),
            method: :post,
            data: { disable_with: 'Loading...',
                    confirm: 'Are you sure you want to cancel this session? This will make ' \
                             'this session unavailable for this date but instead create ' \
                             'an open club session for this same date and time. It will also ' \
                             'refund all signed up users their credits back, and notify them ' \
                             'via SMS.' }
  end

  index do
    selectable_column
    id_column
    column :location_name
    column :skill_level do |session|
      session.skill_level_name || 'N/A'
    end
    column :recurring, &:recurring_text
    column :time do |session|
      session.time.strftime(Session::TIME_FORMAT)
    end
    column :start_time
    column :end_time
    column :duration do |session|
      "#{session.duration_minutes} mins"
    end
    column :cost_credits do |session|
      session.open_club? ? 'N/A' : session.cost_credits
    end
    column :max_capacity do |session|
      session.max_capacity || 'N/A'
    end
    column :max_first_timers do |session|
      session.max_first_timers || 'No restriction'
    end
    number_column :cc_cash_earned, as: :currency
    column :active, &:active?
    toggle_bool_column :is_open_club
    toggle_bool_column :skill_session
    toggle_bool_column :women_only
    toggle_bool_column :members_only
    toggle_bool_column :coming_soon
    toggle_bool_column :is_private

    actions unless params['scope'] == 'deleted'
  end

  form do |f|
    f.inputs 'Session Details' do
      f.input :location
      f.input :skill_level
      f.input :is_open_club
      f.input :skill_session
      f.input :women_only
      f.input :all_skill_levels_allowed
      f.input :allow_back_to_back_reservations
      f.input :coming_soon
      f.input :is_private
      f.input :members_only
      f.input :products,
              collection: Product.recurring.order(price: :asc),
              label: 'Allowed Members',
              hint: 'If not set, it means all members are allowed to book this session.',
              input_html: { class: 'w-64' }
      f.input :start_time,
              as: :datepicker,
              datepicker_options: { min_date: Date.current },
              input_html: { autocomplete: :off }
      f.input :end_time,
              as: :datepicker,
              datepicker_options: { min_date: Date.current },
              input_html: { autocomplete: :off }
      f.input :time
      f.input :duration_minutes
      f.input :cost_credits
      f.input :max_capacity
      f.input :max_first_timers,
              hint: 'If not set, it means there\'s no restriction on the amount of first timers ' \
                    'users who can book.'
      f.input :guests_allowed,
              hint: 'Number of guests allowed per session. If not set, ' \
                    'it means that guests are not allowed for this session.'
      f.input :guests_allowed_per_user,
              hint: 'Number of guests allowed per user for this session.'
      f.input :cc_cash_earned
      f.input :default_referee, collection: User.referees
      f.input :default_sem, collection: User.sems
      f.input :default_coach, collection: User.coaches
      li do
        f.label 'Schedule'
        f.select_recurring :recurring,
                           nil,
                           { allow_blank: true },
                           data: { select2: false },
                           class: 'w-40 p-2 border-gray-300 rounded'
      end
    end

    f.inputs 'Session Exceptions' do
      f.has_many :session_exceptions, allow_destroy: true do |p|
        p.input :date, as: :datepicker, input_html: { autocomplete: :off }
      end
    end

    f.inputs 'Extra information' do
      f.input :theme_title
      f.input :theme_subheading
      f.input :theme_description
    end

    if session.shooting_machines?
      f.inputs 'Shooting Machines' do
        f.has_many :shooting_machines, allow_destroy: true do |p|
          p.input :start_time, as: :time_picker, input_html: { autocomplete: :off }
          p.input :end_time, as: :time_picker, input_html: { autocomplete: :off }
          p.input :price
        end
      end
    end

    f.actions
  end

  show title: proc { |session|
    date = params[:date]
    if date.present?
      "Session for #{date} at #{session.time.strftime(Session::TIME_FORMAT)}"
    else
      "Session #{session.id}"
    end
  } do
    date = params[:date]

    attributes_table do
      row :id
      row :start_time
      row :end_time
      row :time do |session|
        session.time.strftime(Session::TIME_FORMAT)
      end
      row :duration do |session|
        "#{session.duration_minutes} mins"
      end
      row :cost_credits
      row :max_capacity do |session|
        session.max_capacity || 'N/A'
      end
      row :max_first_timers do |session|
        session.max_first_timers || 'No restriction'
      end
      number_row :cc_cash_earned, as: :currency
      row :recurring, &:recurring_text
      row :location_name
      row :skill_level do |session|
        session.skill_level_name || 'N/A'
      end

      row :is_open_club
      row :skill_session
      row :women_only
      row :members_only
      if session.members_only
        row :members_allowed do |session|
          allowed_products = session.products
          allowed_products.any? ? allowed_products.map(&:name).split(', ') : 'All members'
        end
      end
      row :all_skill_levels_allowed
      row :allow_back_to_back_reservations
      row :coming_soon
      row :is_private
      row :guests_allowed
      row :guests_allowed_per_user
      row :votes do |session|
        votes_by_date = session.user_session_votes
                               .group(:date)
                               .order(:date)
                               .count
                               .map do |votes_date, votes_count|
          content_tag(:div, "#{votes_date}: #{votes_count}")
        end

        safe_join(votes_by_date)
      end
      row :default_referee do |session|
        session.skill_session ? 'N/A' : session.default_coach
      end
      row :default_sem do |session|
        session.skill_session ? 'N/A' : session.default_coach
      end
      row :default_coach do |session|
        session.skill_session ? session.default_coach : 'N/A'
      end
      row 'History' do
        link_to 'Link to History', history_admin_session_path(session.id)
      end
      row :created_at
      row :updated_at
    end

    panel 'Time exceptions' do
      table_for session.session_exceptions.order(date: :desc) do
        column :id
        column :date
      end
    end

    panel 'Extra information' do
      table_for session do
        column :theme_title
        column :theme_subheading
        column :theme_description
      end
    end

    if session.shooting_machines?
      panel 'Shooting machines' do
        table_for session.shooting_machines.order(start_time: :asc) do
          column :id
          number_column :price, as: :currency
          column :start_time, &:start_time_str
          column :end_time, &:end_time_str
          if date.present?
            column :reserved do |shooting_machine|
              shooting_machine.reserved?(date)
            end
          end
        end
      end
    end

    if date.present?
      panel 'Employees' do
        referee = resource.referee(date)
        sem = resource.sem(date)
        coach = resource.coach(date)

        is_edit = params[:edit_employees].present? ||
                  (!resource.skill_session && (referee.nil? || sem.nil?)) ||
                  (resource.skill_session && coach.nil?)

        if is_edit
          render partial: 'edit_employees', locals: {
            selected_session: resource,
            date:,
            referee:,
            sem:,
            coach:
          }
        else
          render partial: 'show_employees', locals: {
            date:,
            referee:,
            sem:,
            coach:
          }
        end
      end

      panel 'Arrived Users' do
        user_sessions = resource.user_sessions
                                .reserved_or_confirmed
                                .by_date(date)
                                .checked_in
                                .includes(shooting_machine_reservations: :shooting_machine,
                                          user: [:last_checked_in_user_session,
                                                 { active_subscription: :product,
                                                   image_attachment: :blob }])
                                .order(assigned_team: :desc, updated_at: :asc)

        render partial: 'checked_in_user_sessions', locals: {
          date:,
          user_sessions_by_team: user_sessions.group_by(&:assigned_team),
          jersey_rental_price: ENV.fetch('JERSEY_RENTAL_PRICE', nil),
          towel_rental_price: ENV.fetch('TOWEL_RENTAL_PRICE', nil)
        }
      end

      panel 'Yet to Arrive Users' do
        user_sessions = resource.user_sessions
                                .joins(:user)
                                .reserved_or_confirmed
                                .by_date(date)
                                .not_checked_in
                                .includes(shooting_machine_reservations: :shooting_machine,
                                          user: [:last_checked_in_user_session,
                                                 { active_subscription: :product,
                                                   image_attachment: :blob }])
                                .order('LOWER(users.first_name) ASC, LOWER(users.last_name) ASC')

        render partial: 'not_checked_in_user_sessions', locals: {
          date:,
          user_sessions:,
          jersey_rental_price: ENV.fetch('JERSEY_RENTAL_PRICE', nil),
          towel_rental_price: ENV.fetch('TOWEL_RENTAL_PRICE', nil)
        }
      end

      if resource.guests_allowed?
        panel 'Guests' do
          guests = resource.guests(date).not_canceled.includes(user_session: :user)
          render partial: 'guests', locals: { guests: }
        end
      end

      panel 'Waitlist' do
        waitlist = resource.waitlist(date)
                           .not_success
                           .includes(user: [:last_checked_in_user_session,
                                            { active_subscription: :product,
                                              image_attachment: :blob }])

        render partial: 'waitlist', locals: { waitlist:, time_zone: session.time_zone }
      end

      panel 'Create User Session Manually' do
        users_for_select = User.sorted_by_full_name.map { |user| [user.full_name, user.id] }

        render partial: 'create_user_session', locals: {
          date:,
          users_for_select:
        }
      end
    end
  end

  controller do
    def destroy
      session = Session.find(params[:id])

      if session.destroy
        flash[:notice] = 'Session successfully destroyed'
      else
        flash[:error] = session.errors.full_messages
      end

      redirect_to admin_sessions_path
    end
  end

  member_action :history do
    session = Session.find(params[:id])
    session_versions = session.versions
    session_exception_versions = PaperTrail::Version.where(item_type: 'SessionException')
                                                    .where_object_changes(session_id: session.id)

    versions = session_versions.or(session_exception_versions).reorder(created_at: :desc).last(30)

    render 'admin/shared/history', locals: { versions: }
  end

  member_action :assign_employees, method: :put do
    referee_id = params[:referee_id]
    sem_id = params[:sem_id]
    coach_id = params[:coach_id]
    date = params[:date]

    coach_sessions = resource.coach_sessions.where(date:)
    coach_sessions.destroy_all if resource.skill_session && coach_sessions.any?
    resource.coach_sessions.create!(user_id: coach_id, date:) if coach_id.present?

    referee_sessions = resource.referee_sessions.where(date:)
    referee_sessions.destroy_all if !resource.skill_session && referee_sessions.any?
    resource.referee_sessions.create!(user_id: referee_id, date:) if referee_id.present?

    sem_sessions = resource.sem_sessions.where(date:)
    sem_sessions.destroy_all if !resource.skill_session && sem_sessions.any?
    resource.sem_sessions.create!(user_id: sem_id, date:) if sem_id.present?

    redirect_to admin_root_path, notice: 'Employees assigned successfully'
  end

  member_action :update_user_sessions, method: :post do
    session_id = params[:id]
    date = params[:date]
    user_sessions = params[:user_sessions]
    checked_in_user_session_ids = []
    warnings = []

    user_sessions.each do |user_session_params|
      user_session_id = user_session_params[:id]
      checked_in = user_session_params[:checked_in] == 'true'
      jersey_rental = user_session_params[:jersey_rental] == 'true'
      towel_rental = user_session_params[:towel_rental] == 'true'
      assigned_team = user_session_params[:assigned_team]

      user_session = UserSession.find(user_session_id)
      user = user_session.user

      execute_checked_in_job = checked_in && !user_session.checked_in
      jersey_rental_payment_intent_id = user_session.jersey_rental_payment_intent_id
      towel_rental_payment_intent_id = user_session.towel_rental_payment_intent_id

      if user_session.jersey_rental && !jersey_rental
        result = RefundPayment.call(payment_intent_id: jersey_rental_payment_intent_id)

        if result.failure?
          warnings << "#{user.full_name.titleize}: #{result.message}"
          next
        end

        jersey_rental_payment_intent_id = nil
      elsif !user_session.jersey_rental && jersey_rental
        result = Users::Charge.call(
          user:,
          amount: ENV['JERSEY_RENTAL_PRICE'].to_f,
          description: 'Jersey rental'
        )

        if result.failure?
          warnings << "#{user.full_name.titleize}: #{result.message}"
          next
        end

        jersey_rental_payment_intent_id = result.payment_intent_id
      end

      if user_session.towel_rental && !towel_rental
        result = RefundPayment.call(payment_intent_id: towel_rental_payment_intent_id)

        if result.failure?
          warnings << "#{user.full_name.titleize}: #{result.message}"
          next
        end

        towel_rental_payment_intent_id = nil
      elsif !user_session.towel_rental && towel_rental
        result = Users::Charge.call(
          user:,
          amount: ENV['TOWEL_RENTAL_PRICE'].to_f,
          description: 'Towel rental'
        )

        if result.failure?
          warnings << "#{user.full_name.titleize}: #{result.message}"
          next
        end

        towel_rental_payment_intent_id = result.payment_intent_id
      end

      user_session.update!(
        checked_in:,
        jersey_rental:,
        jersey_rental_payment_intent_id:,
        towel_rental:,
        towel_rental_payment_intent_id:,
        assigned_team:
      )

      checked_in_user_session_ids << user_session_id if execute_checked_in_job
    end

    if checked_in_user_session_ids.present?
      # Perform in 15 minutes in case front desk guy checked in wrong user by accident
      ::Sessions::CheckInUsersJob.set(wait: 15.minutes)
                                 .perform_later(checked_in_user_session_ids,
                                                checked_in_at: Time.now.to_i)
      ::Sonar::FirstSessionSmsJob.set(wait: 15.minutes)
                                 .perform_later(checked_in_user_session_ids)
    end

    if warnings.present?
      flash[:warning] = warnings
    else
      flash[:notice] = 'Users sessions updated successfully'
    end

    redirect_to admin_session_path(id: session_id, date:)
  end

  member_action :create_user_session, method: :post do
    session_id = params[:id]
    user_id = params[:user_id]
    date = params[:date]
    not_charge_user_credit = params[:not_charge_user_credit] == 'true'

    session = Session.find(session_id)
    user = User.find(user_id)

    if session.not_canceled_reservations(date).exists?(user_id:)
      flash[:error] = 'The player is already in the session'
      return redirect_to admin_session_path(id: session_id, date:)
    end

    if user_id.empty?
      flash[:error] = 'You need to select a player'
      return redirect_to admin_session_path(id: session_id, date:)
    end

    ActiveRecord::Base.transaction do
      Users::ClaimFreeSession.call(user:)

      UserSessions::Create.call(
        session:,
        user:,
        date:,
        not_charge_user_credit:
      )
    end

    redirect_to admin_session_path(id: session_id, date:),
                notice: 'User session created successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_session_path(id: session_id, date:)
  end

  member_action :cancel_user_session, method: :post do
    session_id = params[:id]
    date = params[:date]
    user_session = UserSession.find(params[:user_session_id])

    UserSessions::Cancel.call(user_session:)

    redirect_to admin_session_path(id: session_id, date:),
                notice: 'User session canceled successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_session_path(id: session_id, date:)
  end

  member_action :no_show_user_session, method: :post do
    session_id = params[:id]
    date = params[:date]
    user_session = UserSession.find(params[:user_session_id])

    UserSessions::NoShow.call(user_session:)

    redirect_to admin_session_path(id: session_id, date:),
                notice: 'User session marked as no show successfully'
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_session_path(id: session_id, date:)
  end

  member_action :cancel, method: :post do
    session = Session.find(params[:id])
    date = Date.parse(params[:date])
    with_open_club = params[:with_open_club] == 'true'

    Sessions::Cancel.call(
      session:,
      date:,
      with_open_club:
    )

    notice = if with_open_club
               'Session canceled and open club created successfully'
             else
               'Session canceled successfully'
             end

    redirect_to admin_scheduler_path, notice:
  rescue StandardError => e
    flash[:error] = e.message
    redirect_to admin_session_path(id: params[:id], date: params[:date])
  end
end
