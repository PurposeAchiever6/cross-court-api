if Rails.env.development?
  AdminUser.create!(email: 'admin@example.com', password: 'password')

  Location.create!(name: 'DTLA', address: '333 North Mission Road', lat: 34.0520842000,
                   lng: -118.2273522000, city: 'Los Angeles', zipcode: '90033',
                   time_zone: 'America/Los_Angeles', state: 'CA', description: 'DTLA')
end
