# frozen_string_literal: true
class ScsbStatus < HealthMonitor::Providers::Base
  def check!
    # the endpoint /actuator/health isn't working
    # but would be an more ideal place to check
    status_uri = URI(Requests::Config[:scsb_base])
    req = Net::HTTP::Get.new(status_uri)
    response = Net::HTTP.start(status_uri.hostname, status_uri.port, use_ssl: true) { |http| http.request(req) }
    raise "SCSB has an invalid status" unless response.code == "200"
  end
end
