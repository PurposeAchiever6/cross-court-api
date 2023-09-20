ActiveAdmin.register Location do
  menu label: 'Locations', parent: 'Sessions', priority: 1

  permit_params :name, :address, :lat, :lng, :city, :zipcode, :time_zone, :state, :description,
                :max_sessions_booked_per_day, :max_skill_sessions_booked_per_day,
                :free_session_miles_radius, :allowed_late_arrivals,
                :late_arrival_minutes, :late_arrival_fee, :sklz_late_arrival_fee,
                :miles_range_radius, :late_cancellation_fee, :late_cancellation_reimburse_credit,
                images: []

  form do |f|
    f.inputs 'Location Details' do
      f.input :name
      f.input :images, as: :file, input_html: { multiple: true }
      f.input :city
      f.input :zipcode
      f.input :time_zone, as: :select, collection: ActiveSupport::TimeZone::MAPPING.values.sort
      f.input :address
      f.input :state, as: :select, collection: Location::STATES
      f.input :description
    end

    f.inputs 'Location Settings' do
      f.input :miles_range_radius,
              hint: 'If outside this radius, a warning message will show up on signup'
      f.input :free_session_miles_radius,
              hint: 'The radius in miles from this location for which users are selected ' \
                    'for a free session'
      f.input :max_sessions_booked_per_day,
              hint: 'Maximum amount of normal sessions that a user can book for the same day. ' \
                    'If not set, it means there\'s no restriction'
      f.input :max_skill_sessions_booked_per_day,
              hint: 'Maximum amount of skill sessions that a user can book for the same day. ' \
                    'If not set, it means there\'s no restriction'
      f.input :allowed_late_arrivals,
              hint: 'How many times a user can be late for a session before starting to charge ' \
                    'them the late arrival fee'
      f.input :late_arrival_minutes,
              hint: 'How many minutes is considered a late check in'
      f.input :late_arrival_fee,
              hint: 'Cost of the late arrival fee for normal sessions. If set to zero, users ' \
                    'will not be charged on late check ins'
      f.input :sklz_late_arrival_fee,
              hint: 'Cost of the late arrival fee for SKLZ sessions. If set to zero, users ' \
                    'will not be charged on late check ins'
      f.input :late_cancellation_fee,
              hint: 'Cost of the late cancellation fee for sessions. If set to zero, users ' \
                    'will not be charged on late cancellations'
      f.input :late_cancellation_reimburse_credit,
              label: 'Should user credit be refunded on late cancellations?'
    end

    f.inputs 'Location Address' do
      f.input :lat, as: :hidden
      f.input :lng, as: :hidden
      f.latlng api_key_env: 'GOOGLE_API_KEY',
               default_lat: ENV.fetch('DEFAULT_LATITUDE', nil),
               default_lng: ENV.fetch('DEFAULT_LONGITUDE', nil)
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
      row 'Self Check-In URL' do |location|
        link_to 'Link', location.self_check_in_url, target: '_blank', rel: 'noopener'
      end
    end

    panel 'Settings' do
      attributes_table_for location do
        row :miles_range_radius
        row :free_session_miles_radius
        row :max_sessions_booked_per_day do |location|
          location.max_sessions_booked_per_day || 'No restriction'
        end
        row :max_skill_sessions_booked_per_day do |location|
          location.max_skill_sessions_booked_per_day || 'No restriction'
        end
        row :allowed_late_arrivals
        row :late_arrival_minutes
        number_row :late_arrival_fee, as: :currency
        number_row :sklz_late_arrival_fee, as: :currency
        number_row :late_cancellation_fee, as: :currency
        row :late_cancellation_reimburse_credit
      end
    end
  end
end
