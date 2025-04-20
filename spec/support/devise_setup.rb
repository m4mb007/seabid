require 'devise'

RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Warden::Test::Helpers
end

# Configure Devise test mode
Devise.setup do |config|
  config.stretches = 1
  config.sign_out_via = :delete
end 