ActiveAdmin.register Location do
  permit_params :name, :direction, :lat, :lng, :city, :zipcode, :image

  form do |f|
    f.inputs 'Location Details' do
      f.input :name
      f.input :image, as: :file
      f.input :city
      f.input :zipcode
      f.input :time_zone, as: :select, options: ActiveSupport::TimeZone::MAPPING.keys.sort
      f.input :direction
      f.input :lat, as: :hidden
      f.input :lng, as: :hidden
      f.latlng api_key_env: 'GOOGLE_API_KEY',
               default_lat: ENV['DEFAULT_LATITUDE'],
               default_lng: ENV['DEFAULT_LONGITUDE']
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :city
      row :zipcode
      row :direction
      row :image do |location|
        image_tag polymorphic_url(location.image) if location.image.attached?
      end
    end
  end
end
