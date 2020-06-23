# frozen_string_literal: true

require 'rails_helper'

require './lib/orangelight/voyager_patron_client.rb'
require './lib/orangelight/voyager_account.rb'

RSpec.describe VoyagerPatronClient do
  context 'A valid Princeton User' do
    sample_patron = { 'barcode' => '2232323232323',
                      'last_name' => 'smith',
                      'patron_id' => '777777' }
    subject(:client) { described_class.new(sample_patron) }

    let(:voyager_xml_namespace) { 'http://www.endinfosys.com/Voyager/myAccount' }
    let(:voyager_authenticate_response) { fixture('/authenticate_patron_response_success.xml') }
    let(:voyager_dbkey_response) { fixture('/voyager_db_info_response.xml') }
    let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
    let(:voyager_successful_cancel_request) { fixture('/successful_cancelled_request.xml') }
    let(:voyager_failed_cancel_request) { fixture('/failed_cancel_request_response.xml') }
    let(:voyager_successful_renew_request) { fixture('/successful_voyager_renew_response.xml') }
    let(:voyager_failed_renew_request) { fixture('/failed_renew_request_recall.xml') }
    let(:items_to_cancel) { ['item-1722964:holdrecall-602673:type-R'] }
    let(:renew_item_list) { %w[6526437 91173] }
    let(:valid_patron_record_uri) { "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronHomeUbId=1@DB&patronId=#{sample_patron['patron_id']}" }
    let(:valid_db_key_uri) { "#{ENV['voyager_api_base']}/vxws/dbInfo?option=dbinfo" }
    let(:valid_authenticate_uri) { "#{ENV['voyager_api_base']}/vxws/AuthenticatePatronService" }
    let(:valid_cancel_request_uri) { "#{ENV['voyager_api_base']}/vxws/CancelService" }
    let(:valid_renew_request_uri) { "#{ENV['voyager_api_base']}/vxws/RenewService" }

    before do
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: voyager_account_response, headers: {})

      stub_request(:get, valid_db_key_uri)
        .to_return(status: 200, body: voyager_dbkey_response, headers: {})

      stub_request(:post, valid_authenticate_uri)
        .with(headers: { 'Content-type' => 'application/xml' }, body: client.authenticate_patron_xml)
        .to_return(status: 200, body: voyager_authenticate_response, headers: {})

      stub_request(:post,  valid_cancel_request_uri)
        .with(headers: { 'Content-type' => 'application/xml' }, body: client.cancel_xml_string(items_to_cancel, client.dbkey))
        .to_return(status: 200, body: voyager_successful_cancel_request, headers: {})

      stub_request(:post,  valid_renew_request_uri)
        .with(headers: { 'Content-type' => 'application/xml' }, body: client.renew_xml_string(renew_item_list))
        .to_return(status: 200, body: voyager_successful_renew_request, headers: {})
    end

    describe '#myaccount' do
      it 'Returns a successful http response' do
        expect(client.myaccount).to be_a(Faraday::Response)
        expect(client.myaccount.status).to eq(200)
      end

      it 'Returns a well-formed XML Document' do
        expect(client.myaccount.body).to be_a(String)
        expect(Nokogiri::XML(client.myaccount.body)).to be_a(Nokogiri::XML::Document)
      end

      context 'Connectivity Error' do
        before do
          stub_request(:get, valid_patron_record_uri).to_raise(Faraday::Error::ConnectionFailed)
        end
        it "Returns false when it can't connect" do
          expect { client.myaccount }.not_to raise_error
          expect(client.myaccount).to be false
        end
      end
    end

    describe '#authenticate' do
      it 'Returns a valid HTTP response with XML data' do
        expect(client.authenticate).to be_a(Faraday::Response)
        expect(client.authenticate.status).to eq(200)
      end

      it 'Returns a well-formed XML Document' do
        expect(client.authenticate.body).to be_a(String)
        expect(Nokogiri::XML(client.authenticate.body)).to be_a(Nokogiri::XML::Document)
      end

      context 'Connectivity Error' do
        before do
          stub_request(:post, valid_authenticate_uri).to_raise(Faraday::Error::ConnectionFailed)
        end
        it "Returns false when it can't connect" do
          expect { client.authenticate }.not_to raise_error
          expect(client.authenticate).to be false
        end
      end
    end

    describe '#dbkey' do
      it 'Returns current DB key' do
        expect(client.dbkey).to eq('QA20082DB28836413431413')
      end

      context 'Connectivity Error' do
        before do
          stub_request(:get, valid_db_key_uri).to_raise(Faraday::Error::ConnectionFailed)
        end
        it "Returns false when it can't connect" do
          expect { client.dbkey }.not_to raise_error
          expect(client.dbkey).to be false
        end
      end
    end

    describe '#cancel_active_requests' do
      it 'Returns a Voyager Account Object when successful' do
        expect(client.cancel_active_requests(items_to_cancel)).to be_a(VoyagerAccount)
      end

      it 'A successfully cancel request response does not include the item request requested to be cancelled' do
        voyager_account = client.cancel_active_requests(items_to_cancel)
        expect(voyager_account.avail_items).to be_nil
        expect(voyager_account.request_items).to be_nil
      end

      it 'A failed cancel request response still includes the item requested to be cancelled' do
        stub_request(:post, valid_cancel_request_uri)
          .with(headers: { 'Content-type' => 'application/xml' }, body: client.cancel_xml_string(items_to_cancel, client.dbkey))
          .to_return(status: 200, body: voyager_failed_cancel_request, headers: {})
        expect(client.cancel_active_requests(items_to_cancel).request_items.size).to eq(1)
      end
      context 'Connectivity Error' do
        before do
          stub_request(:post, valid_cancel_request_uri).to_raise(Faraday::Error::ConnectionFailed)
        end
        it "Returns false when it can't connect" do
          expect { client.cancel_active_requests(items_to_cancel) }.not_to raise_error
          expect(client.cancel_active_requests(items_to_cancel)).to be false
        end
      end
    end

    describe '#cancel_xml_string' do
      it 'is a string of well-formed XML' do
        expect(client.cancel_xml_string(items_to_cancel, client.dbkey)).to be_a(String)
        expect(Nokogiri::XML(client.cancel_xml_string(items_to_cancel, client.dbkey))).to be_a(Nokogiri::XML::Document)
      end

      it 'Contains the item id, hold id, and recall id' do
        cancel_xml = Nokogiri::XML(client.cancel_xml_string(items_to_cancel, client.dbkey))
        # cancel string item-1722964:holdrecall-602673:type-R
        expect(cancel_xml.xpath('//myac:itemID', 'myac' => voyager_xml_namespace).text).to eq('1722964')
        expect(cancel_xml.xpath('//myac:holdRecallID', 'myac' => voyager_xml_namespace).text).to eq('602673')
        expect(cancel_xml.xpath('//myac:holdType', 'myac' => voyager_xml_namespace).text).to eq('R')
      end
    end

    describe '#renewal_request' do
      it 'Returns a Voyager Account Object when successful' do
        expect(client.renewal_request(renew_item_list)).to be_a(VoyagerAccount)
      end

      it 'A successfully renewed item has a positive renew status' do
        voyager_account = client.renewal_request(renew_item_list)
        expect(voyager_account.charged_items).to be_truthy
        expect(voyager_account.charged_items.size).to eq(1)
        expect(voyager_account.charged_items.first).to have_key(:renew_status)
        expect(voyager_account.charged_items.first[:renew_status]['status']).to eq('Renewed')
      end

      it 'a failed renew item request response has a message' do
        stub_request(:post, valid_renew_request_uri)
          .with(headers: { 'Content-type' => 'application/xml' }, body: client.renew_xml_string(renew_item_list))
          .to_return(status: 200, body: voyager_failed_renew_request, headers: {})
        expect(client.renewal_request(renew_item_list).charged_items.size).to eq(3)
        expect(client.renewal_request(renew_item_list).charged_items[1]).to have_key(:messages)
        expect(client.renewal_request(renew_item_list).charged_items[1][:messages]['message']).to eq('Items with recall requests may not be renewed.')
      end

      it 'a failed renew item request response has renew status with a block' do
        stub_request(:post, valid_renew_request_uri)
          .with(headers: { 'Content-type' => 'application/xml' }, body: client.renew_xml_string(renew_item_list))
          .to_return(status: 200, body: voyager_failed_renew_request, headers: {})
        expect(client.renewal_request(renew_item_list).charged_items.size).to eq(3)
        expect(client.renewal_request(renew_item_list).charged_items[1]).to have_key(:renew_status)
        expect(client.renewal_request(renew_item_list).charged_items[1][:renew_status]['status']).to eq('Not Renewed')
      end

      context 'Connectivity Error' do
        before do
          stub_request(:post, valid_renew_request_uri).to_raise(Faraday::Error::ConnectionFailed)
        end
        it "Returns false when it can't connect" do
          expect { client.renewal_request(renew_item_list) }.not_to raise_error
          expect(client.renewal_request(renew_item_list)).to be false
        end
      end
    end

    describe '#renew_xml_string' do
      it 'is a string of well-formed XML' do
        expect(client.renew_xml_string(renew_item_list)).to be_a(String)
        expect(Nokogiri::XML(client.renew_xml_string(renew_item_list))).to be_a(Nokogiri::XML::Document)
      end

      it 'contains the item id of the item to be renewed' do
        renew_xml = Nokogiri::XML(client.renew_xml_string(renew_item_list))
        expect(renew_xml.xpath('//myac:itemId', 'myac' => voyager_xml_namespace).first.text).to eq(renew_item_list.first)
        expect(renew_xml.xpath('//myac:itemId', 'myac' => voyager_xml_namespace).last.text).to eq(renew_item_list.last)
      end
    end
  end
end
