# frozen_string_literal: true

require Rails.root.join('lib', 'orangelight', 'middleware', 'invalid_parameter_handler')

Rails.application.configure do
  # Before filter for Flipflop dashboard. Replace with a lambda or method name
  # defined in ApplicationController to implement access control.
  # config.flipflop.dashboard_access_filter = :verify_admin!

  # By default, when set to `nil`, strategy loading errors are suppressed in test
  # mode. Set to `true` to always raise errors, or `false` to always warn.
  config.flipflop.raise_strategy_errors = true

  # Settings specified here will take precedence over those in config/application.rb.

  # The test environment is used exclusively to run your application's
  # test suite. You never need to work with it otherwise. Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs. Don't rely on the data there!
  config.cache_classes = true

  # Eager loading loads your whole application. When running a single test locally,
  # this probably isn't necessary. It's a good idea to do in a continuous integration
  # system, or in some way before deploying your code.
  config.eager_load = ENV['CI'].present?

  # Configure static asset server for tests with Cache-Control for performance.
  config.serve_static_files = true
  config.static_cache_control = 'public, max-age=3600'

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = :none

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test
  config.action_mailer.deliver_later_queue_name = 'mailers'
  config.active_job.queue_adapter = :sidekiq
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
  config.action_mailer.default_options = {
    from: 'test@test.com'
  }

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true
  config.middleware.use Orangelight::Middleware::InvalidParameterHandler
  
  config.assets.debug = true
end
