ActiveAdmin.register SessionGuest do
  menu label: 'Session Guests', parent: 'Sessions', priority: 4

  permit_params :first_name, :last_name, :phone_number, :email, :user_session_id, :access_code,
                :state

  filter :first_name
  filter :last_name
  filter :phone_number
  filter :email
  filter :user_session_id
  filter :access_code
  filter :state, as: :select, collection: SessionGuest.states

  form do |f|
    f.inputs 'Session guest details' do
      f.input :first_name
      f.input :last_name
      f.input :phone_number
      f.input :email
      f.input :access_code
      f.input :state, as: :select, collection: SessionGuest.states.keys.to_a
      f.input :user_session,
              as: :select,
              collection: UserSession.includes(:user, session: :location).future.order(:date, :time)
    end

    f.actions
  end

  index do
    id_column
    column :first_name
    column :last_name
    column :phone_number
    column :email
    column :user_session_id
    column :access_code
    tag_column :state

    actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :phone_number
      row :email
      row :user_session_id
      row :access_code
      tag_row :state
      row :created_at
      row :updated_at
    end
  end
end
