# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require_relative "lando_env"
require_relative "../lib/orangelight/browse_lists"

# For reasons we don't fully understand, yell is messing up the Rails6 zeitwerk
# auto-loader in some cases, in our consuming app that uses kithe.
# https://github.com/rudionrails/yell/issues/60
#
# Manually requiring yell here seems to avoid it. We believe switching yell to use
# Module#prepend might also resolve.
# https://github.com/rudionrails/yell/pull/61
#
# We don't actually use yell in kithe, it's just here via traject. If traject stops using yell,
# we can stop require'ing it here, it's just a weird workaround.
require 'yell'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Settings for request system
# TODO: Get rid of this.
begin
  ENV.update YAML.load_file('config/requests.yml')[Rails.env]
rescue
  {}
end

module Orangelight
  class Application < Rails::Application
    # Before filter for Flipflop dashboard. Replace with a lambda or method name
    # defined in ApplicationController to implement access control.
    config.flipflop.dashboard_access_filter = :verify_admin!

    # By default, when set to `nil`, strategy loading errors are suppressed in test
    # mode. Set to `true` to always raise errors, or `false` to always warn.
    config.flipflop.raise_strategy_errors = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # IE Edge
    config.action_dispatch.default_headers['X-UA-Compatible'] = 'IE=edge,chrome=1'
    require Rails.root.join('lib', 'custom_public_exceptions')
    require Rails.root.join('lib', 'omniauth', 'strategies', 'barcode')
    require Rails.root.join('lib', 'omniauth', 'strategies', 'alma')
    config.exceptions_app = CustomPublicExceptions.new(Rails.public_path)

    # Redirect to CAS logout after signing out of Orangelight
    config.x.after_sign_out_url = 'https://fed.princeton.edu/cas/logout'

    config.alma = config_for(:alma).with_indifferent_access

    # See https://github.com/projectblacklight/blacklight/issues/2768
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, Hash, HashWithIndifferentAccess]

    BlacklightDynamicSitemap::Engine.config.minimum_average_chunk = 500
    config.autoloader = :zeitwerk
  end
end
