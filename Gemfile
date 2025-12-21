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
