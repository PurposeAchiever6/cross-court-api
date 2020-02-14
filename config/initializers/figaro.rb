# Put here the variables used by all the environments
variables = %w[
  SERVER_URL
  PASSWORD_RESET_URL
  FREE_SESSION_PRICE
  MAX_CAPACITY
  CANCELLATION_PERIOD
  CONFIRMATION_PERIOD
  ULTIMATUM_PERIOD
]

unless Rails.env.test?
  # Variables not used by the test environment
  variables += %w[SECRET_KEY_BASE]
end

Figaro.require_keys(variables)
