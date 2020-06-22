# frozen_string_literal: true

require 'faraday'
require 'faraday-cookie_jar'

class IlliadPatronClient
  def initialize(patron)
    @barcode = patron['barcode']
    @last_name = patron['last_name']
    @patron_id = patron['patron_id']
    @netid = patron['netid']
    @illiad_api_key = illiad_api_key
    @illiad_api_base = ENV['ILLIAD_API_BASE_URL']
  end

  def illiad_api_key
    if !Rails.env.test?
      (ENV['ILLIAD_API_KEY']).to_s
    else
      'TESTME'
    end
  end

  def outstanding_ill_requests
    begin
      response = conn.get do |req|
        req.url "/ILLiadWebPlatform/Transaction/UserRequests/#{@netid}?$filter=TransactionStatus ne 'Cancelled by ILL Staff'"
        req.headers['Accept'] = 'application/json'
        req.headers['ApiKey'] = @illiad_api_key
      end
    rescue Faraday::Error::ConnectionFailed
      Rails.logger.info("Unable to Connect to #{@illiad_api_base}")
      return false
    end
    response
  end

  def cancel_ill_requests(transactions)
    begin
      response = conn.put do |req|
        req.url "ILLiadWebPlatform/transaction/#{transactions[0]}/route"
        req.headers['ApiKey'] = @illiad_api_key
        req.headers['Content-Type'] = 'application/json'
        req.body = { Status: 'Cancelled by Customer' }.to_json
      end
    rescue Faraday::Error::ConnectionFailed
      Rails.logger.info("Unable to Connect to #{@illiad_api_base}")
      return false
    end
    response
  end

  def bodytest
    {
      Status: 'Cancelled by Customer'
    }
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
