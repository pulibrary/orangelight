# frozen_string_literal: true
class BibdataStatus < HealthMonitor::Providers::Base
  attr_reader :critical

  def initialize
    super
    @critical = false
  end

  def check!
    status_uri = URI("#{Requests.config[:bibdata_base]}/health.json")
    req = Net::HTTP::Get.new(status_uri)
    response = Net::HTTP.start(status_uri.hostname, status_uri.port, use_ssl: true) { |http| http.request(req) }
    json_response = JSON.parse(response.body)
    raise "Bibdata has an invalid status" unless json_response["status"] == "ok"
  end
end
