require 'faraday'
require 'faraday-cookie_jar'

class VoyagerPatronClient

  def initialize(patron)
    @barcode = patron['barcode']
    @last_name = patron['last_name']
    @patron_id = patron['patron_id']
    @ub_id = "1@PRINCETONDB20050302104001" #patron['ub_id'] is this global for all patrons?
  end

  def myaccount
    begin
      response = conn.get "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{@patron_id}&patronHomeUbId={@ub_id}"
    rescue Faraday::Error::ConnectionFailed => e
      logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    response
  end

  def authenticate_patron_xml
    string = %Q(<?xml version="1.0" encoding="UTF-8"?>
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
        req.body = "#{authenticate_patron_xml}"
      end
    rescue Faraday::Error::ConnectionFailed => e
      logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    response
  end

  # The current "dbkey" needed as part of cancel request item boilerplate
  def dbkey
    # see https://developers.exlibrisgroup.com/voyager/apis/XMLoverHTTPWebServices/DBInfoService
    begin
      response = conn.get do |req| 
        req.url '/vxws/dbInfo?option=dbinfo'
        req.headers['Content-Type'] = 'application/xml'
      end
    rescue Faraday::Error::ConnectionFailed => e
      logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    extract_db_keys(response.body)
  end

  def cancel_active_requests items
    xml = cancel_xml_string(items, self.dbkey)
    self.authenticate
    begin
      response = conn.post do |req| 
        req.url '/vxws/CancelService'
        req.body = xml
        req.headers['Content-Type'] = 'application/xml'
      end
    rescue Faraday::Error::ConnectionFailed => e
      logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    response
  end

  def cancel_xml_string(items, dbkey)
    string = %Q(<?xml version="1.0" encoding="UTF-8"?>
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
    items.each do |item|
      item_string = %Q(<myac:requestIdentifier>
          <myac:itemID>#{item['item_id']}</myac:itemID>
          <myac:holdRecallID>#{item['hold_recall_id']}</myac:holdRecallID>
          <myac:holdType>#{item['hold_type']}</myac:holdType>
          <myac:dbKey>#{dbkey}</myac:dbKey>
          <myac:ubHoldingsDbKey>0</myac:ubHoldingsDbKey>
        </myac:requestIdentifier>
      )
      cancel_item_string = cancel_item_string + item_string
    end
    cancel_item_string
  end

  def renewal_request items
    self.authenticate # this needs to be called with the same connection
    
    begin
      response = conn.post do |req| 
        req.url '/vxws/RenewService'
        req.body = "#{renew_xml_string(items)}"
        req.headers['Content-Type'] = 'application/xml'
      end
    rescue Faraday::Error::ConnectionFailed => e
      logger.info("Unable to Connect to #{ENV['voyager_api_base']}")
      return false
    end
    response

  end

  def renew_xml_string items
    %Q(<?xml version="1.0" encoding="UTF-8"?>
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

  def format_renewal_items items
    items_string = ""
    items.each do |item|
      string = %Q(
        <myac:itemIdentifier>
          <myac:itemId>#{item["itemId"]}</myac:itemId>
          <myac:ubId>#{@ub_id}</myac:ubId>
        </myac:itemIdentifier>
      )
      items_string = items_string + string
    end
    items_string
  end

  def conn
    Faraday.new(:url=> "#{ENV['voyager_api_base']}") do |builder|
      builder.use :cookie_jar
      builder.adapter Faraday.default_adapter
      builder.response :logger
    end
  end

  protected

  def extract_db_keys dbxml
    doc = Nokogiri::XML(dbxml)
    doc.xpath('//xmlns:dbKey').text
  end

end