$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "thermos/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "thermos"
  s.version     = Thermos::VERSION
  s.authors     = ["Andrew Thal"]
  s.email       = ["hi@athal7.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Thermos."
  s.description = "TODO: Description of Thermos."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails"

  s.add_development_dependency "sqlite3"
end
