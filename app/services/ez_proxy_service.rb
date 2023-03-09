# frozen_string_literal: true

class EzProxyService
  def self.ez_proxy_url?(url)
    host = URI(url.to_s).host
    EZ_PROXY_HOST_LIST.include?(host)
  rescue URI::InvalidURIError
    Rails.logger.warn("EzProxyService encountered bad url: #{url}")
    false
  end

  def self.ez_proxy_url(url)
    if EzProxyService.ez_proxy_url?(url)
      "#{Requests.config['proxy_base']}#{url}"
    else
      url.to_s
    end
  end
end
