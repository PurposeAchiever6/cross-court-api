ActiveAdmin.register Location do
  permit_params :name, :address, :lat, :lng, :city, :zipcode, :image, :time_zone, :state, :description

  form do |f|
    f.inputs 'Location Details' do
      f.input :name
      f.input :image, as: :file
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
      row :image do |location|
        image_tag polymorphic_url(location.image) if location.image.attached?
      end
    end
  end
end