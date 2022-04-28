# frozen_string_literal: true

require 'faraday'
require 'faraday-cookie_jar'

class IlliadPatronClient
  def initialize(patron)
    @barcode = patron['barcode']
    @last_name = patron['last_name']
    @patron_id = patron['patron_id']
    @netid = patron['netid']
    @illiad_api_key = Requests.config["illiad_api_key"]
    @illiad_api_base = Requests.config["illiad_api_base"]
  end

  def outstanding_ill_requests
    # Use "ProcessType eq Borrowing" for interlibrary loan and digital requests
    begin
      response = conn.get do |req|
        # If we wanted to divide the results RequestType%20eq%20'Loan' is Inter Library Loan and RequestType%20eq%20'Article' is digitization
        req.url "/ILLiadWebPlatform/Transaction/UserRequests/#{@netid}?$filter=ProcessType%20eq%20'Borrowing'%20and%20" \
                "TransactionStatus%20ne%20'Request%20Finished'%20and%20not%20startswith%28TransactionStatus,'Cancelled'%29"
        req.headers['Accept'] = 'application/json'
        req.headers['ApiKey'] = @illiad_api_key
      end
    rescue Faraday::Error::ConnectionFailed
      Rails.logger.info("Unable to Connect to #{@illiad_api_base}")
      return []
    end
    parse_response(response)
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

    def parse_response(response)
      return [] unless response.success?
      json_data = JSON.parse(response.body)
      # allow dispplay of either Loan or Article fields
      json_data.each do |item|
        item["PhotoJournalTitle"] ||= item["LoanTitle"]
        item["PhotoArticleAuthor"] ||= item["LoanAuthor"]
      end
      json_data
    end

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
end
