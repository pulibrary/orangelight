# frozen_string_literal: true
class BibdataStatus < HealthMonitor::Providers::Base
  def check!
    status_uri = URI("#{Requests::Config[:bibdata_base]}/health.json")
    req = Net::HTTP::Get.new(status_uri)
    response = Net::HTTP.start(status_uri.hostname, status_uri.port, use_ssl: true) { |http| http.request(req) }
    json_response = JSON.parse(response.body)
    raise "Bibdata has an invalid status" unless json_response["status"] == "ok"
  end
end