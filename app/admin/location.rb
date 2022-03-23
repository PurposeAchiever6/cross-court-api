ActiveAdmin.register Location do
  permit_params :name, :address, :lat, :lng, :city, :zipcode, :time_zone, :state, :description,
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
      f.input :lat, as: :hidden
      f.input :lng, as: :hidden
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
    column :images do |location|
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
    end
  end
end
