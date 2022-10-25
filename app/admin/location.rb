ActiveAdmin.register Location do
  menu label: 'Locations', parent: 'Sessions', priority: 1

  permit_params :name, :address, :lat, :lng, :city, :zipcode, :time_zone, :state, :description,
                :max_sessions_booked_per_day, :max_skill_sessions_booked_per_day,
                :free_session_miles_radius, images: []

  form do |f|
    f.inputs 'Location Details' do
      f.input :name
      f.input :images, as: :file, input_html: { multiple: true }
      f.input :city
      f.input :zipcode
      f.input :time_zone, as: :select, collection: ActiveSupport::TimeZone::MAPPING.values.sort
      f.input :address
      f.input :state, as: :select, collection: Location::STATES
      f.input :lat, as: :hidden
      f.input :lng, as: :hidden
      f.input :free_session_miles_radius
      f.input :max_sessions_booked_per_day,
              hint: 'If not set, it means there\'s no restriction on the amount of normal ' \
                    'sessions a user can book per day.'
      f.input :max_skill_sessions_booked_per_day,
              hint: 'If not set, it means there\'s no restriction on the amount of skill ' \
                    'sessions a user can book per day.'
      f.input :description
      f.latlng api_key_env: 'GOOGLE_API_KEY',
               default_lat: ENV['DEFAULT_LATITUDE'],
               default_lng: ENV['DEFAULT_LONGITUDE']
    end
    f.actions
  end

  index do
    selectable_column
    id_column
    column :name
    column :city
    column :zipcode
    column :time_zone
    column :address
    column :state
    column :free_session_miles_radius
    column :max_sessions_booked_per_day do |location|
      location.max_sessions_booked_per_day || 'No restriction'
    end
    column :max_skill_sessions_booked_per_day do |location|
      location.max_skill_sessions_booked_per_day || 'No restriction'
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :city
      row :zipcode
      row :time_zone
      row :address
      row :state
      row :description
      row :free_session_miles_radius
      row :max_sessions_booked_per_day do |location|
        location.max_sessions_booked_per_day || 'No restriction'
      end
      row :max_skill_sessions_booked_per_day do |location|
        location.max_skill_sessions_booked_per_day || 'No restriction'
      end
      row :images do |location|
        if location.images.attached?
          div class: 'flex' do
            location.images.includes(:blob).each do |location_img|
              div class: 'mr-2' do
                image_tag location_img, class: 'max-w-200'
              end
            end
          end
        end
      end
    end
  end
end
