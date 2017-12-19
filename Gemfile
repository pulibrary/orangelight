source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.0'
# Use postgresql as the database for Active Record
gem 'pg'
# Blacklight
gem 'blacklight', git: 'https://github.com/projectblacklight/blacklight', branch: 'release-6.x'

gem 'rsolr'

# slider limit support
gem 'blacklight_range_limit', '~> 6.2.1'
# advanced search functionality
gem 'blacklight_advanced_search', '~> 6.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Modernizr.js library
gem 'modernizr-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.2.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Static pages
gem 'high_voltage', '~> 3.0.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring', group: :development

# jquery multiselect plugin for advanced search
gem 'chosen-rails'

gem 'introjs-rails', git: 'https://github.com/videmor/intro.js-rails.git', branch: 'update.introjs'

# Capistrano
gem 'blacklight-marc', '~> 6.1'
gem 'capistrano', '~> 3.4.0'
gem 'devise', '~> 4.2'
gem 'devise-guests', '~> 0.5'
gem 'faraday'
gem 'faraday-cookie_jar'
gem 'omniauth-cas'
gem 'solr_wrapper', '~> 1.0'
gem 'yajl-ruby', '>= 1.3.1', require: 'yajl'

# rspec, just like jettywrapper appear necessary for cap currently
gem 'capybara'
gem 'coveralls', require: false
gem 'lcsort', '~>0.9'
gem 'library_stdnums'
gem 'newrelic_rpm'
gem 'rspec-rails', '~> 3.4'
gem 'rubocop', '~> 0.49', require: false
gem 'rubocop-rspec', '~> 1.20.1'
gem 'stringex', git: 'https://github.com/pulibrary/stringex.git', tag: 'vpton.2.5.2.2'

gem 'mail_form'
gem 'string_rtl'

gem 'requests', git: 'https://github.com/pulibrary/requests.git'

gem 'borrow_direct', '~> 1.2.0'

gem 'blacklight_unapi', git: 'https://github.com/pulibrary/blacklight_unapi.git', branch: 'blacklight_6'

gem 'jquery-datatables-rails', '~> 3.3.0'

gem 'openurl', '~> 1.0'

gem 'honeybadger', '~> 3.1'

gem 'sitemap_generator', '~> 6.0'

gem 'voight_kampff', '~> 1.1'

group :development do
  gem 'capistrano-rails', '~> 1.1.6'
end

group :test do
  gem 'factory_bot_rails', require: false
  gem 'launchy'
  gem 'poltergeist'
  gem 'rails-controller-testing'
  gem 'webmock', require: false
end

group :development, :test do
  gem 'pry-byebug'
end
