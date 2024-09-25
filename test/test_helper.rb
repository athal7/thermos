# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
ActiveRecord::Migrator.migrations_paths = [
  File.expand_path("../../test/dummy/db/migrate", __FILE__),
]
require "rails/test_help"

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new
require "minitest/mock"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path =
    File.expand_path("../fixtures", __FILE__)
  ActionDispatch::IntegrationTest.fixture_path =
    ActiveSupport::TestCase.fixture_path
elsif ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [
    File.expand_path("../fixtures", __FILE__),
  ]
  ActionDispatch::IntegrationTest.fixture_paths =
    ActiveSupport::TestCase.fixture_paths
end
ActiveSupport::TestCase.fixtures :all

ActiveJob::Base.queue_adapter = :inline
ActiveSupport.test_order = :random

def clear_cache
  Thermos::BeverageStorage.instance.empty
  Rails.cache.clear
end
