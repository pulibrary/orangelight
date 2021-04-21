# frozen_string_literal: true

require_relative 'production'

# Mailcatcher configuration
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = { :address => '127.0.0.1', :port => 1025 }
config.action_mailer.raise_delivery_errors = false
