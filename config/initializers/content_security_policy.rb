# frozen_string_literal: true

Rails.application.config.content_security_policy_report_only = true
# Rails.application.config.content_security_policy_nonce_generator = -> request { SecureRandom.base64(16) }

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self, :https
  policy.font_src    :self, :https, :data
  policy.img_src     :self, :https, :data
  policy.object_src  :none
  policy.script_src  :self, :https

  # TODO: Upgrade MathJax to the latest version, using yarn/npm rather than the CDN
  policy.style_src   :self, "'unsafe-inline'"
  # policy.style_src   :self, :https
  # policy.report_uri -> { "https://api.honeybadger.io/v1/browser/csp?api_key=#{ENV['HONEYBADGER_API_KEY']}&report_only=true&env=#{Rails.env}&context[user_id]=#{respond_to?(:current_user) ? current_user&.id : nil}" }
end
