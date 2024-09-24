# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.frame_ancestors :self, 'https://princeton.libwizard.com', 'https://princeton.instructure.com'
    policy.connect_src :self, '*.princeton.edu', 'http://localhost:*', :https
    policy.font_src    :self, :data, 'https://maxcdn.bootstrapcdn.com', 'https://use.typekit.net', 'https://fonts.gstatic.com'
    policy.img_src     :self, :https, :data
    policy.media_src   :self, :data
    policy.script_src  :self, :https, :unsafe_eval, :unsafe_inline
    policy.style_src   :self, :https, :unsafe_inline
    policy.frame_src   :self, 'https://figgy.princeton.edu', 'https://*.doubleclick.net'
    policy.report_uri -> { "https://api.honeybadger.io/v1/browser/csp?api_key=#{ENV.fetch('HONEYBADGER_API_KEY', nil)}&report_only=true&env=#{Rails.env}&context[user_id]=#{respond_to?(:current_user) ? current_user&.id : nil}" }
  end

  # Report violations without enforcing the policy.
  config.content_security_policy_report_only = true
end
