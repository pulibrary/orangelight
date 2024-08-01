# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 6.1'

gem 'alma'
gem 'babel-transpiler'
gem 'bcrypt_pbkdf'
# Blacklight
gem 'blacklight', '~> 7.37.0'
# advanced search functionality
gem 'blacklight_advanced_search', '~> 7.0'
gem 'blacklight_dynamic_sitemap'
gem 'blacklight-marc', '~>8.1'
# slider limit support
gem 'blacklight_range_limit', '~> 8.2'
gem 'blacklight_unapi', git: 'https://github.com/pulibrary/blacklight_unapi.git', branch: 'main'
gem 'bootstrap', '~> 4.6'
# Capistrano
# In the Capistrano documentation, it has these limited to the development group, and `require: false``
gem 'capistrano', '~> 3.4'
gem 'capistrano-passenger'
gem 'ddtrace', '~> 1.14.0'
# Authentication and authorization
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.5'
gem 'ed25519'
gem 'email_validator'
gem 'faraday'
gem 'faraday-cookie_jar'
gem 'flipflop'
gem 'friendly_id', '~> 5.4.2'
gem 'global'
gem 'health-monitor-rails', '~> 12.2'
# Static pages
gem 'high_voltage'
gem 'honeybadger'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# Use jquery as the JavaScript library
# jest tests use yarn to get jquery; if upgrading here keep that version in sync
gem 'jquery-datatables' # used by requests (please do not remove)
gem 'jquery-rails'
gem 'lcsort', '>= 0.9.1'
gem 'library_stdnums'
gem 'lograge'
gem 'logstash-event'
gem 'matrix'
# For memory profiling
# See https://github.com/MiniProfiler/rack-mini-profiler#memory-profiling for usage
gem 'memory_profiler'
gem 'net-imap', require: false
gem 'net-ldap'
gem 'net-pop', require: false
gem 'net-smtp', require: false
# Authenticate using CAS
gem 'omniauth-cas'
gem 'omniauth-rails_csrf_protection'
gem 'openurl', '~> 1.0'
# Use postgresql as the database for Active Record
gem 'pg'
gem 'puma', '~> 6.4'
# For limiting request rates
gem 'rack-attack'
# For profiling
gem 'rack-mini-profiler'
gem 'rake'
# Needed for rack-mini-profiler storage
gem 'redis'
# Interact with Solr
gem 'rsolr'
# Should this be in the test, development group?
gem 'rspec-rails'
gem 'rubyzip', '>= 1.2.2'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0'
gem 'simple_form'
gem 'sneakers'
gem 'sprockets-es6'
# For call-stack profiling flamegraphs
gem 'stackprof'
gem 'stringex', git: 'https://github.com/pulibrary/stringex.git', tag: 'vpton.2.5.2.2'
gem 'string_rtl'
gem 'terser'
gem 'view_component', '< 3.0.0'
gem 'vite_rails'
gem 'voight_kampff', require: 'voight_kampff/rails'
gem 'whenever'
gem 'yajl-ruby', '>= 1.3.1', require: 'yajl'
gem 'yard'

group :development do
  gem 'capistrano-rails'
end

group :test do
  gem 'axe-core-api'
  gem 'axe-core-rspec'
  gem 'factory_bot_rails', require: false
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'timecop'
  gem 'vcr'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'bixby', '~> 5.0'
  gem 'capybara'
  gem 'coveralls_reborn'
  gem "erb_lint", require: false
  gem "erblint-github"
  gem 'pry-byebug'
  gem 'solargraph'
end
