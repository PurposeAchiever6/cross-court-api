ActiveAdmin.register Location do
  permit_params :name, :direction, :lat, :lng, :city, :zipcode

  form do |f|
    f.inputs 'Location Details' do
      f.input :name
      f.input :city
      f.input :zipcode
      f.input :direction
      f.input :lat, as: :hidden
      f.input :lng, as: :hidden
      f.latlng api_key_env: 'GOOGLE_API_KEY',
               default_lat: ENV['DEFAULT_LATITUDE'],
               default_lng: ENV['DEFAULT_LONGITUDE']
    end
    f.actions
  end
end
