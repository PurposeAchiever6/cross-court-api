ActiveAdmin.register Location do
  permit_params :name, :direction, :latitude, :longitude

  form do |f|
    f.inputs 'Location Details' do
      f.input :name
      f.input :direction
      f.input :latitude
      f.input :longitude
    end
    f.actions
  end
end
