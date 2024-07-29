# frozen_string_literal: true
class StackmapStatus < HealthMonitor::Providers::Base
  def check!
    status_uri = URI("https://www.stackmapintegration.com/princeton-blacklight/StackMap.min.js")
    req = Net::HTTP::Head.new(status_uri)
    response = Net::HTTP.start(status_uri.hostname, status_uri.port, use_ssl: true) { |http| http.request(req) }
    raise "Stackmap has an invalid status" unless response.code == "200"
  end
end
