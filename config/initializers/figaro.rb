# Put here the variables used by all the environments
variables = %w[
  SERVER_URL
  PASSWORD_RESET_URL
  FREE_SESSION_PRICE
  CANCELLATION_PERIOD
]

unless Rails.env.test?
  # Variables not used by the test environment
  variables += %w[SECRET_KEY_BASE]
end

Figaro.require_keys(variables)
