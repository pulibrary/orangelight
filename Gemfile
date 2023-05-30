# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 6.1', '>= 6.1.7.1'

gem 'alma'
gem 'babel-transpiler'
gem 'bcrypt_pbkdf'
# Blacklight
gem 'blacklight', '~> 7.0'
# advanced search functionality
gem 'blacklight_advanced_search', '~> 7.0'
gem 'blacklight_dynamic_sitemap', '~> 0.6.0'
gem 'blacklight-marc', github: 'projectblacklight/blacklight-marc', ref: 'a463221'
# slider limit support
gem 'blacklight_range_limit', '~> 8.2'
gem 'blacklight_unapi', git: 'https://github.com/pulibrary/blacklight_unapi.git', branch: 'main'
gem 'bootstrap', '~> 4.6'
gem 'bootstrap-select-rails'
# Capistrano
# In the Capistrano documentation, it has these limited to the development group, and `require: false``
gem 'capistrano', '~> 3.4'
gem 'capistrano-passenger'
# jquery multiselect plugin for advanced search
gem 'chosen-rails'
gem 'cobravsmongoose', '~> 0.0.2'
gem 'ddtrace', '~> 0.54.2'
# Authentication and authorization
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.5'
gem 'ed25519'
gem 'email_validator'
gem 'faraday', '~> 0.17'
gem 'faraday-cookie_jar'
gem 'flipflop'
gem 'font-awesome-rails'
gem 'friendly_id', '~> 5.4.2'
gem 'global'
# Static pages
gem 'high_voltage', '~> 3.0.0'
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
gem 'mail_form'
gem 'matrix'
# For memory profiling
# See https://github.com/MiniProfiler/rack-mini-profiler#memory-profiling for usage
gem 'memory_profiler'
# Modernizr.js library
gem 'modernizr-rails'
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
gem 'puma', '~> 6.0'
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
gem 'terser', '~> 1.1'
gem 'vite_rails', '3.0.12'
gem 'voight_kampff'
gem 'whenever', '~> 0.11'
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
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'timecop'
  gem 'vcr'
  gem 'webdrivers'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'bixby', '~> 5.0'
  gem 'capybara'
  gem 'coveralls_reborn'
  gem 'pry-byebug'
  gem 'solargraph'
end
