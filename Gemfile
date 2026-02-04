# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

rails_version = ENV['RAILS_VERSION'] || 'default'
rails = case rails_version
        when 'main'
          { github: 'rails/rails' }
        when 'default'
          '~> 8.0'
        else
          "~> #{rails_version}"
        end

gem 'rails', rails

# Required for Rails 8.0+
gem 'logger'
gem 'ostruct'
gem 'benchmark'
gem 'mutex_m'
gem 'drb'
gem 'bigdecimal'

# Minitest 6.0 is incompatible with Rails 7.x test runner (ArgumentError in line_filtering.rb)
# Rails 8.0+ works with Minitest 6.0, which also requires the extracted minitest-mock gem
case rails_version
when '7.1', '7.2'
  gem 'minitest', '< 6'
else
  gem 'minitest', '>= 6'
  gem 'minitest-mock'
end
