Geocoder.configure(
  always_raise: :all,
  lookup: Rails.env.test? ? :test : :google,
  api_key: ENV.fetch('GOOGLE_API_KEY', nil)
)
