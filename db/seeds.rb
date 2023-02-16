Dir[File.join(Rails.root, 'db', 'seeds/**', '*.rb')].each do |seed_file|
  require seed_file
end

if Rails.env.development?
  admin_user = AdminUser.find_or_create_by(email: 'admin@example.com')
  if !admin_user
    admin_user.password = 'password'
    admin_user.save!
  end

  Location.find_or_create_by(
    name: 'DTLA',
    address: '333 North Mission Road',
    lat: 34.0520842000,
    lng: -118.2273522000,
    city: 'Los Angeles',
    zipcode: '90033',
    time_zone: 'America/Los_Angeles',
    state: 'CA',
    description: 'DTLA'
  )
end


Seeds::RolesAndPermissions.run
