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

  def outstanding_ill_requests
    # Use "ProcessType eq Borrowing" for digital requests
    begin
      response = conn.get do |req|
        req.url "/ILLiadWebPlatform/Transaction/UserRequests/#{@netid}?$filter=ProcessType%20eq%20'Borrowing'%20and%20" \
                "TransactionStatus%20ne%20'Request%20Finished'%20and%20not%20startswith%28TransactionStatus,'Cancelled'%29"
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
      response = []
      transactions.each do |transaction|
        response << cancel_ill_request(transaction)
      end
    rescue Faraday::Error::ConnectionFailed
      Rails.logger.info("Unable to Connect to #{@illiad_api_base}")
      return false
    end
    response
  end

  private

    def cancel_ill_request(transaction)
      conn.put do |req|
        req.url "ILLiadWebPlatform/transaction/#{transaction}/route"
        req.headers['ApiKey'] = @illiad_api_key
        req.headers['Content-Type'] = 'application/json'
        req.body = { Status: 'Cancelled by Customer' }.to_json
      end
    end

    def conn
      Faraday.new(url: @illiad_api_base.to_s) do |builder|
        builder.use :cookie_jar
        builder.adapter Faraday.default_adapter
        builder.response :logger
      end
    end

    def illiad_api_key
      if !Rails.env.test?
        (ENV['ILLIAD_API_KEY']).to_s
      else
        'TESTME'
      end
    end
end
