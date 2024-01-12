# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

Rails.application.config.action_dispatch.cookies_serializer = :json

# Strict Same Site Protection protects users from CSRF attacks from non-Princeton
# domains.  However, when running orangelight on localhost, the CAS login page is
# on a different domain from orangelight (localhost vs. *.princeton.edu), so
# we exclude the dev environment from these protections so they can use CAS locally.
Rails.application.config.action_dispatch.cookies_same_site_protection = :strict unless Rails.env.development?
