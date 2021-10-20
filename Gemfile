# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4'
# Use postgresql as the database for Active Record
gem 'pg'
# Blacklight
gem 'blacklight', '~> 7.0.0'

gem 'rsolr'

# slider limit support
gem 'blacklight_range_limit'
# advanced search functionality
gem 'blacklight_advanced_search', git: 'https://github.com/projectblacklight/blacklight_advanced_search', branch: 'master'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Modernizr.js library
gem 'modernizr-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2.0'

# Use jquery as the JavaScript library
# jest tests use yarn to get jquery; if upgrading here keep that version in sync
gem 'jquery-datatables' # used by requests (please do not remove)
gem 'jquery-rails'

# Static pages
gem 'high_voltage', '~> 3.0.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# jquery multiselect plugin for advanced search
gem 'chosen-rails'

gem 'introjs-rails', git: 'https://github.com/videmor/intro.js-rails.git', branch: 'update.introjs'

# Capistrano
gem 'blacklight-marc', git: 'https://github.com/projectblacklight/blacklight-marc.git', ref: 'c0ff1d9'
gem 'capistrano', '~> 3.4.0'
gem 'devise', '>= 4.6.0'
gem 'devise-guests', '~> 0.5'
gem 'faraday', '~> 0.17'
gem 'faraday-cookie_jar'
gem 'global'
gem 'omniauth-cas'
gem 'yajl-ruby', '>= 1.3.1', require: 'yajl'

gem 'babel-transpiler'
gem 'bootstrap', '~> 4.6'
gem 'capybara'
gem 'coveralls', require: false
gem 'ddtrace'
gem 'font-awesome-rails'
gem 'lcsort', '>= 0.9.1'
gem 'library_stdnums'
gem 'rspec-rails', '~> 3.4'
gem 'rubyzip', '>= 1.2.2'
gem 'sneakers'
gem 'sprockets-es6'
gem 'stringex', git: 'https://github.com/pulibrary/stringex.git', tag: 'vpton.2.5.2.2'

gem 'mail_form'
gem 'string_rtl'

gem 'requests', git: 'https://github.com/pulibrary/requests.git', branch: 'main'

gem 'borrow_direct', git: 'https://github.com/pulibrary/borrow_direct.git', branch: 'generate_query_encoding_fix'

gem 'blacklight_unapi', git: 'https://github.com/pulibrary/blacklight_unapi.git', branch: 'master'

gem 'openurl', '~> 1.0'

gem 'honeybadger'

gem 'sitemap_generator', '~> 6.0'

gem 'voight_kampff', '~> 1.1'

gem 'webpacker'

gem 'lograge'

gem 'logstash-event'

gem 'whenever', '~> 0.11'
gem 'yard'

group :development do
  gem 'capistrano-rails'
end

group :test do
  gem "axe-core-rspec"
  gem 'factory_bot_rails', require: false
  gem 'launchy'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'webdrivers'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'bixby'
  gem 'pry-byebug'
  gem 'solargraph'
end
