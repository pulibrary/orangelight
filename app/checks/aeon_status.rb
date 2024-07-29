# frozen_string_literal: true
class AeonStatus < HealthMonitor::Providers::Base
  def check!
    base_uri = Requests::Config[:aeon_base]
    status_host = base_uri[0, base_uri.rindex("/")]
    status_uri = URI("#{status_host}/aeon/api/SystemInformation/Version")
    req = Net::HTTP::Get.new(status_uri)
    response = Net::HTTP.start(status_uri.hostname, status_uri.port, use_ssl: true) { |http| http.request(req) }
    raise "Aeon has an invalid status" unless response.code == "200"
  end
end
