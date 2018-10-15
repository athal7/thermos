$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "thermos/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "thermos"
  s.version     = Thermos::VERSION
  s.authors     = ["Andrew Thal"]
  s.email       = ["hi@athal7.com"]
  s.homepage    = "https://github.com/athal7/thermos"
  s.summary     = "Always-warm, auto-rebuilding rails caching without timers or touching."
  s.description = "Thermos is a library for caching in rails that re-warms caches in the background based on model changes."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.required_ruby_version = ">= 2.4.0"

  s.add_dependency "rails", ">= 5.0.0"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rake"
end
