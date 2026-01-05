# frozen_string_literal: true

source 'https://gem.coop'

gem 'rails', '~> 8.1'

gem 'alma'
gem 'babel-transpiler'
gem 'bcrypt_pbkdf'
# Blacklight
gem 'blacklight', '~> 8.12'
gem 'blacklight_dynamic_sitemap'
gem 'blacklight-hierarchy'
gem 'blacklight-marc', '~>8.1'
# slider limit support
gem 'blacklight_range_limit', '~> 9.2.0'
gem 'bootstrap', '~> 5.3.0'
gem 'dartsass-sprockets'
gem 'psych'
# support for non-marc citations (e.g. SCSB records)
gem 'citeproc-ruby'
gem 'csl-styles'
gem 'deprecation'
# Authentication and authorization
gem 'devise'
gem 'devise-guests'
gem 'ed25519'
gem 'email_validator'
gem 'faraday'
gem 'faraday-cookie_jar'
gem "ffi", force_ruby_platform: true
gem 'flipflop'
gem 'global'
gem 'health-monitor-rails', '12.9.0'
# Static pages
gem 'high_voltage'
gem 'honeybadger'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# Use jquery as the JavaScript library
# jest tests use yarn to get jquery; if upgrading here keep that version in sync
gem 'jquery-datatables' # used by requests (please do not remove)
gem 'jquery-rails'
gem 'kicks'
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
gem 'puma', '~> 7.1'
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
gem 'sidekiq'
gem 'simple_form'
gem 'sprockets-es6'
gem 'sprockets-rails'
# For call-stack profiling flamegraphs
gem 'stackprof'
gem 'stringex', git: 'https://github.com/pulibrary/stringex.git', branch: 'main'
gem 'string_rtl'
gem 'terser'
gem 'view_component'
gem 'vite_rails'
gem 'voight_kampff', require: 'voight_kampff/rails'
gem 'whenever'
gem 'yajl-ruby', '>= 1.3.1', require: 'yajl'
gem 'yard'

group :development do
  gem 'benchmark-ips'
  gem 'capistrano', '~> 3.20', require: false
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'reek'
end

group :test do
  gem 'axe-core-api'
  gem 'axe-core-rspec'
  gem 'factory_bot_rails', require: false
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'byebug'
  gem 'rubocop-rspec', require: false
  gem 'rubocop-rspec_rails', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  gem 'capybara'
  gem 'coveralls_reborn', require: false
  gem "erb_lint", require: false
  gem "erblint-github"
end
group :production do
  gem 'datadog', require: 'datadog/auto_instrument'
end
