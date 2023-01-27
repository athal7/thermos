# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'thermos/version'

Gem::Specification.new do |s|
  s.name = 'thermos'
  s.version = Thermos::VERSION
  s.authors = ['Andrew Thal']
  s.email = ['athal7@me.com']
  s.homepage = 'https://github.com/athal7/thermos'
  s.summary = 'Always-warm, auto-rebuilding rails caching without timers or touching.'
  s.description = <<~HEREDOC
    Thermos is a library for caching in rails that re-warms caches
    in the background based on model changes.
  HEREDOC
  s.license = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.required_ruby_version = ['>= 2.7.0', '< 3.2.0']

  s.add_runtime_dependency 'rails'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'prettier'
  s.add_development_dependency 'psych', '< 4.0.0'
end
