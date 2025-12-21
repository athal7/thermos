require File.expand_path("../boot", __FILE__)

require "rails/all"

Bundler.require(*Rails.groups)
require "thermos"

module Dummy
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults Rails::VERSION::STRING.to_f

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # Use a real queuing backend for Active Job (and separate queues per environment).
    config.active_job.queue_adapter = :test
  end
end
