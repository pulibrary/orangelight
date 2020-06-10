# frozen_string_literal: true

require 'faraday'
require 'faraday-cookie_jar'

class IlliadAccount
  def initialize(patron)
    @barcode = patron['barcode']
    @last_name = patron['last_name']
    @patron_id = patron['patron_id']
    @netid = patron['netid']
    @illiad_api_key = (ENV['ILLIAD_API_KEY']).to_s
    @illiad_api_base = 'https://lib-illiad.princeton.edu'
  end

  def verify_user
    begin
      response = conn.get do |req|
        req.url "/ILLiadWebPlatform/Users/#{@netid}"
        req.headers['Accept'] = 'application/json'
        req.headers['ApiKey'] = @illiad_api_key
      end
    rescue Faraday::Error::ConnectionFailed
      Rails.logger.info("Unable to Connect to #{@illiad_api_base}")
      return false
    end
    response
  end

  private
    def conn
      Faraday.new(url: @illiad_api_base.to_s) do |builder|
        builder.use :cookie_jar
        builder.adapter Faraday.default_adapter
        builder.response :logger
      end
    end
end
