require 'faraday'
require 'faraday-cookie_jar'

class VoyagerPatronClient
  def initialize(patron)
    @barcode = patron['barcode']
    @last_name = patron['last_name']
    @patron_id = patron['patron_id']
    @ub_id = (ENV['voyager_ub_id']).to_s
  end

  def myaccount
    begin
      response = conn.get "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{@patron_id}&patronHomeUbId=1@DB"
    rescue Faraday::Error::ConnectionFailed => e
      Rails.logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    Rails.logger.info(response.body.to_s)
    response
  end

  # The current value for "dbkey" is needed as part of cancel request item boilerplate
  def dbkey
    # see https://developers.exlibrisgroup.com/voyager/apis/XMLoverHTTPWebServices/DBInfoService
    begin
      response = conn.get do |req|
        req.url '/vxws/dbInfo?option=dbinfo'
        req.headers['Content-Type'] = 'application/xml'
      end
    rescue Faraday::Error::ConnectionFailed => e
      Rails.logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    Rails.logger.info(response.body.to_s)
    extract_db_keys(response.body)
  end

  def authenticate_patron_xml
    string = %(<?xml version="1.0" encoding="UTF-8"?>
<ser:serviceParameters xmlns:ser="http://www.endinfosys.com/Voyager/serviceParameters">
  <ser:parameters>
  </ser:parameters>
    <ser:patronIdentifier lastName="#{@last_name}">
    <ser:authFactor type="B">#{@barcode}</ser:authFactor>
  </ser:patronIdentifier>
</ser:serviceParameters>
    )
    string
  end

  def authenticate
    begin
      response = conn.post do |req|
        req.url '/vxws/AuthenticatePatronService'
        req.headers['Content-Type'] = 'application/xml'
        req.body = authenticate_patron_xml.to_s
      end
    rescue Faraday::Error::ConnectionFailed => e
      Rails.logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    Rails.logger.info(response.body.to_s)
    response
  end

  def cancel_active_requests(items)
    authenticate
    begin
      response = conn.post do |req|
        req.url '/vxws/CancelService'
        req.body = cancel_xml_string(items, dbkey)
        Rails.logger.info(req.body.to_s)
        req.headers['Content-Type'] = 'application/xml'
      end
    rescue Faraday::Error::ConnectionFailed => e
      Rails.logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    Rails.logger.info(response.status.to_s)
    Rails.logger.info(Nokogiri::XML(response.body).to_xml.to_s)
    parse_response(response)
  end

  def cancel_xml_string(items, dbkey)
    string = %(<?xml version="1.0" encoding="UTF-8"?>
<ser:serviceParameters xmlns:ser="http://www.endinfosys.com/Voyager/serviceParameters">
   <ser:parameters/>
   <ser:patronIdentifier lastName="#{@last_name}" patronHomeUbId="#{@ub_id}" patronId="#{@patron_id}">
      <ser:authFactor type="B">#{@barcode}</ser:authFactor>
   </ser:patronIdentifier>
   <ser:definedParameters xsi:type="myac:myAccountServiceParametersType" xmlns:myac="http://www.endinfosys.com/Voyager/myAccount" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      #{cancel_item_list(items, dbkey)}
   </ser:definedParameters>
</ser:serviceParameters>
    )
  end

  def cancel_item_list(items, dbkey)
    cancel_item_string = ""
    cancelled_items(items).each do |item|
      item_string = %(<myac:requestIdentifier>
          <myac:itemID>#{item['item_id']}</myac:itemID>
          <myac:holdRecallID>#{item['hold_recall_id']}</myac:holdRecallID>
          <myac:holdType>#{item['hold_type']}</myac:holdType>
          <myac:dbKey>#{dbkey}</myac:dbKey>
          <myac:ubHoldingsDbKey>0</myac:ubHoldingsDbKey>
        </myac:requestIdentifier>
      )
      cancel_item_string += item_string
    end
    cancel_item_string
  end

  def renewal_request(items)
    authenticate # this needs to be called with the same connection

    begin
      response = conn.post do |req|
        req.url '/vxws/RenewService'
        Rails.logger.info(items)
        req.body = renew_xml_string(items).to_s
        Rails.logger.info(req.body.to_s)
        req.headers['Content-Type'] = 'application/xml'
      end
    rescue Faraday::Error::ConnectionFailed => e
      Rails.logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    Rails.logger.info(response.status.to_s)
    Rails.logger.info(Nokogiri::XML(response.body).to_xml.to_s)
    parse_response(response)
  end

  def parse_response(response)
    VoyagerAccount.new(response.body) if response.status == 200
  end

  def renew_xml_string(items)
    %(<?xml version="1.0" encoding="UTF-8"?>
<ser:serviceParameters xmlns:ser="http://www.endinfosys.com/Voyager/serviceParameters">
   <ser:parameters/>
   <ser:patronIdentifier lastName="#{@last_name}" patronHomeUbId="#{@ub_id}" patronId="#{@patron_id}">
      <ser:authFactor type="B">#{@barcode}</ser:authFactor>
   </ser:patronIdentifier>
   <ser:definedParameters xsi:type="myac:myAccountServiceParametersType" xmlns:myac="http://www.endinfosys.com/Voyager/myAccount" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
      #{format_renewal_items(items)}
   </ser:definedParameters>
</ser:serviceParameters>
    )
  end

  def format_renewal_items(items)
    items_string = ""
    items.each do |item|
      string = %(
        <myac:itemIdentifier>
          <myac:itemId>#{item}</myac:itemId>
          <myac:ubId>#{@ub_id}</myac:ubId>
        </myac:itemIdentifier>
      )
      items_string += string
    end
    items_string
  end

  private

    def conn
      Faraday.new(url: (ENV['voyager_api_base']).to_s) do |builder|
        builder.use :cookie_jar
        builder.adapter Faraday.default_adapter
        builder.response :logger
      end
    end

    def extract_db_keys(dbxml)
      doc = Nokogiri::XML(dbxml)
      doc.xpath('//xmlns:dbKey').text
    end

    ## return a list of cancelled item strings as a hash
    def cancelled_items(items)
      item_list = []
      items.each do |item|
        item_list.push(cancelled_item(item))
      end
      item_list
    end

    # sprint the cancel item string
    # form item-7114238:holdrecall-587476:type-R
    def cancelled_item(item)
      request_data = item.split(":")
      item_data = {}
      item_data["item_id"] = request_data[0].split('-')[1]
      item_data["hold_recall_id"] = request_data[1].split('-')[1]
      item_data["hold_type"] = request_data[2].split('-')[1]
      item_data
    end
end
