# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'thermos/version'

Gem::Specification.new do |s|
  s.name = 'thermos'
  s.version = Thermos::VERSION
  s.authors = ['Andrew Thal']
  s.email = ['athal7@me.com']
  s.homepage = 'https://github.com/athal7/thermos'
  s.summary = 'Always-warm, auto-rebuilding Rails cache that updates in the background when models change.'
  s.description = <<~HEREDOC
    Thermos is a Rails caching library that keeps your cache always warm by
    automatically rebuilding it in the background when ActiveRecord models change.
    No more stale data from TTL expiration, no more slow cold cache hits, and no
    need to 'touch' associated models. Works with any ActiveJob backend (Sidekiq,
    Solid Queue, etc.) and any cache store (Redis, Memcached, Solid Cache, etc.).
    Perfect for API responses, JSON serialization, and view caching.
  HEREDOC
  s.license = 'MIT'

  s.metadata = {
    'homepage_uri' => s.homepage,
    'source_code_uri' => 'https://github.com/athal7/thermos',
    'changelog_uri' => 'https://github.com/athal7/thermos/releases',
    'rubygems_mfa_required' => 'true',
  }

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.required_ruby_version = '>= 3.2'

  s.add_runtime_dependency 'rails', '>= 7.1', '< 9'
  s.add_development_dependency 'minitest', '~> 6.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'prettier'
end
