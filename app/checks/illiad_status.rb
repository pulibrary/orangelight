# frozen_string_literal: true
class IlliadStatus < HealthMonitor::Providers::Base
  def check!
    status_uri = URI("#{Requests::Config[:illiad_api_base]}/IlliadWebPlatform/SystemInfo/PlatformVersion")
    req = Net::HTTP::Get.new(status_uri)
    response = Net::HTTP.start(status_uri.hostname, status_uri.port, use_ssl: true) { |http| http.request(req) }
    raise "Illiad has an invalid status" unless response.code == "200"
  end
end
