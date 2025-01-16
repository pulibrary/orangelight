# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.frame_ancestors :self, 'https://princeton.libwizard.com', 'https://princeton.instructure.com'

    policy.connect_src :self, '*.princeton.edu', 'http://localhost:*', :https, 'ws://localhost:3036/vite-dev/'
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.media_src   :self, :data
    policy.object_src  :none
    policy.script_src  :self, :https, :unsafe_eval, :unsafe_inline
    policy.style_src   :self, :https, :unsafe_inline
    policy.frame_src   :self, 'https://figgy.princeton.edu', 'https://*.doubleclick.net'
  end
end
