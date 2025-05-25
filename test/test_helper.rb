# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "minitest/autorun"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"

# Configure Rails for testing
class TestApplication < Rails::Application
  config.eager_load = false
  config.session_store :cookie_store, key: "_test_session"
  config.secret_key_base = "test_secret"
  config.logger = Logger.new("/dev/null")
  config.active_support.deprecation = :stderr
end

Rails.application.initialize!

# Now require solidstats after Rails is configured
require "solidstats"

# Require ViewComponent and configure for testing
require "view_component"
require "view_component/test_helpers"

# Configure ViewComponent test helpers
class ActiveSupport::TestCase
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers
end

# Load all component classes
component_files = Dir[File.join(__dir__, "..", "app", "components", "**", "*.rb")]
component_files.sort.each { |f| require f }
class TestApplication < Rails::Application
  config.eager_load = false
  config.session_store :cookie_store, key: "_test_session"
  config.secret_key_base = "test_secret"
  config.logger = Logger.new("/dev/null")
  config.active_support.deprecation = :stderr
end

Rails.application.initialize!

# Require ViewComponent and configure for testing
require "view_component"
require "view_component/test_helpers"

# Configure ViewComponent test helpers
class ActiveSupport::TestCase
  include ViewComponent::TestHelpers
  include Rails.application.routes.url_helpers
end

# Load all component classes
Dir[File.expand_path("../app/components/**/*.rb", __dir__)].sort.each { |f| require f }
