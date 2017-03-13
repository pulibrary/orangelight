require 'rails_helper'

require './lib/orangelight/voyager_patron_client.rb'
require './lib/orangelight/voyager_account.rb'

RSpec.describe VoyagerPatronClient do
  context 'A valid Princeton User' do
    sample_patron = { 'barcode' => '2232323232323',
                      'last_name' => 'smith',
                      'patron_id' => '777777' }
    subject { described_class.new(sample_patron) }
    let(:voyager_xml_namespace) { 'http://www.endinfosys.com/Voyager/myAccount' }
    let(:voyager_authenticate_response) { fixture('/authenticate_patron_response_success.xml') }
    let(:voyager_dbkey_response) { fixture('/voyager_db_info_response.xml') }
    let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
    let(:voyager_successful_cancel_request) { fixture('/successful_cancelled_request.xml') }
    let(:voyager_failed_cancel_request) { fixture('/failed_cancel_request_response.xml') }
    let(:voyager_successful_renew_request) { fixture('/successful_voyager_renew_response.xml') }
    let(:voyager_failed_renew_request) { fixture('/failed_renew_request_recall.xml') }
    let(:items_to_cancel) { ['item-1722964:holdrecall-602673:type-R'] }
    let(:renew_item_list) { %w(6526437 91173) }
    let(:valid_patron_record_uri) { "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronHomeUbId=1@DB&patronId=#{sample_patron['patron_id']}" }
    let(:valid_db_key_uri) { "#{ENV['voyager_api_base']}/vxws/dbInfo?option=dbinfo" }
    let(:valid_authenticate_uri) { "#{ENV['voyager_api_base']}/vxws/AuthenticatePatronService" }
    let(:valid_cancel_request_uri) { "#{ENV['voyager_api_base']}/vxws/CancelService" }
    let(:valid_renew_request_uri) { "#{ENV['voyager_api_base']}/vxws/RenewService" }

    before(:each) do
      stub_request(:get, valid_patron_record_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: voyager_account_response, headers: {})

      stub_request(:get, valid_db_key_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0' })
        .to_return(status: 200, body: voyager_dbkey_response, headers: {})

      stub_request(:post, valid_authenticate_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0', 'Content-type' => 'application/xml' }, body: subject.authenticate_patron_xml)
        .to_return(status: 200, body: voyager_authenticate_response, headers: {})

      stub_request(:post,  valid_cancel_request_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0', 'Content-type' => 'application/xml' }, body: subject.cancel_xml_string(items_to_cancel, subject.dbkey))
        .to_return(status: 200, body: voyager_successful_cancel_request, headers: {})

      stub_request(:post,  valid_renew_request_uri)
        .with(headers: { 'User-Agent' => 'Faraday v0.11.0', 'Content-type' => 'application/xml' }, body: subject.renew_xml_string(renew_item_list))
        .to_return(status: 200, body: voyager_successful_renew_request, headers: {})
    end

    describe '#myaccount' do
      it 'Returns a successful http response' do
        expect(subject.myaccount.is_a?(Faraday::Response)).to be_truthy
        expect(subject.myaccount.status).to eq(200)
      end

      it 'Returns a well-formed XML Document' do
        expect(subject.myaccount.body.is_a?(String)).to be_truthy
        expect(Nokogiri::XML(subject.myaccount.body).is_a?(Nokogiri::XML::Document)).to be_truthy
      end

      context 'Connectivity Error' do
        it "Returns false when it can't connect" do
          allow(subject).to receive(:myaccount) { false }
          expect { subject.myaccount }.not_to raise_error
        end
      end
    end

    describe '#authenticate' do
      it 'Returns a valid HTTP response with XML data' do
        expect(subject.authenticate.is_a?(Faraday::Response)).to be_truthy
        expect(subject.authenticate.status).to eq(200)
      end

      it 'Returns a well-formed XML Document' do
        expect(subject.authenticate.body.is_a?(String)).to be_truthy
        expect(Nokogiri::XML(subject.authenticate.body).is_a?(Nokogiri::XML::Document)).to be_truthy
      end

      context 'Connectivity Error' do
        it "Returns false when it can't connect" do
          allow(subject).to receive(:authenticate) { false }
          expect { subject.authenticate }.not_to raise_error
        end
      end
    end

    describe '#dbkey' do
      it 'Returns current DB key' do
        expect(subject.dbkey).to eq('QA20082DB28836413431413')
      end

      context 'Connectivity Error' do
        it "Returns false when it can't connect" do
          allow(subject).to receive(:dbkey) { false }
          expect { subject.dbkey }.not_to raise_error
        end
      end
    end

    describe '#cancel_active_requests' do
      it 'Returns a Voyager Account Object when successful' do
        expect(subject.cancel_active_requests(items_to_cancel).is_a?(VoyagerAccount)).to be_truthy
      end

      it 'A successfully cancel request response does not include the item request requested to be cancelled' do
        voyager_account = subject.cancel_active_requests(items_to_cancel)
        expect(voyager_account.avail_items).to be_nil
        expect(voyager_account.request_items).to be_nil
      end

      it 'A failed cancel request response still includes the item requested to be cancelled' do
        stub_request(:post, valid_cancel_request_uri)
          .with(headers: { 'User-Agent' => 'Faraday v0.11.0', 'Content-type' => 'application/xml' }, body: subject.cancel_xml_string(items_to_cancel, subject.dbkey))
          .to_return(status: 200, body: voyager_failed_cancel_request, headers: {})
        expect(subject.cancel_active_requests(items_to_cancel).request_items.size).to eq(1)
      end
      context 'Connectivity Error' do
        it "Returns false when it can't connect" do
          allow(subject).to receive(:cancel_active_requests) { false }
          expect { subject.cancel_active_requests }.not_to raise_error
        end
      end
    end

    describe '#cancel_xml_string' do
      it 'is a string of well-formed XML' do
        expect(subject.cancel_xml_string(items_to_cancel, subject.dbkey).is_a?(String)).to be_truthy
        expect(Nokogiri::XML(subject.cancel_xml_string(items_to_cancel, subject.dbkey)).is_a?(Nokogiri::XML::Document)).to be_truthy
      end

      it 'Contains the item id, hold id, and recall id' do
        cancel_xml = Nokogiri::XML(subject.cancel_xml_string(items_to_cancel, subject.dbkey))
        # cancel string item-1722964:holdrecall-602673:type-R
        expect(cancel_xml.xpath('//myac:itemID', 'myac' => voyager_xml_namespace).text).to eq('1722964')
        expect(cancel_xml.xpath('//myac:holdRecallID', 'myac' => voyager_xml_namespace).text).to eq('602673')
        expect(cancel_xml.xpath('//myac:holdType', 'myac' => voyager_xml_namespace).text).to eq('R')
      end
    end

    describe '#renewal_request' do
      it 'Returns a Voyager Account Object when successful' do
        expect(subject.renewal_request(renew_item_list).is_a?(VoyagerAccount)).to be_truthy
      end

      it 'A successfully renewed item has a positive renew status' do
        voyager_account = subject.renewal_request(renew_item_list)
        expect(voyager_account.charged_items).to be_truthy
        expect(voyager_account.charged_items.size).to eq(1)
        expect(voyager_account.charged_items.first).to have_key(:renew_status)
        expect(voyager_account.charged_items.first[:renew_status]['status']).to eq('Renewed')
      end

      it 'a failed renew item request response has a message' do
        stub_request(:post, valid_renew_request_uri)
          .with(headers: { 'User-Agent' => 'Faraday v0.11.0', 'Content-type' => 'application/xml' }, body: subject.renew_xml_string(renew_item_list))
          .to_return(status: 200, body: voyager_failed_renew_request, headers: {})
        expect(subject.renewal_request(renew_item_list).charged_items.size).to eq(3)
        expect(subject.renewal_request(renew_item_list).charged_items[1]).to have_key(:messages)
        expect(subject.renewal_request(renew_item_list).charged_items[1][:messages]['message']).to eq('Items with recall requests may not be renewed.')
      end

      it 'a failed renew item request response has renew status with a block' do
        stub_request(:post, valid_renew_request_uri)
          .with(headers: { 'User-Agent' => 'Faraday v0.11.0', 'Content-type' => 'application/xml' }, body: subject.renew_xml_string(renew_item_list))
          .to_return(status: 200, body: voyager_failed_renew_request, headers: {})
        expect(subject.renewal_request(renew_item_list).charged_items.size).to eq(3)
        expect(subject.renewal_request(renew_item_list).charged_items[1]).to have_key(:renew_status)
        expect(subject.renewal_request(renew_item_list).charged_items[1][:renew_status]['status']).to eq('Not Renewed')
      end

      context 'Connectivity Error' do
        it "Returns false when it can't connect" do
          allow(subject).to receive(:renewal_request) { false }
          expect { subject.renewal_request }.not_to raise_error
        end
      end
    end

    describe '#renew_xml_string' do
      it 'is a string of well-formed XML' do
        expect(subject.renew_xml_string(renew_item_list).is_a?(String)).to be_truthy
        expect(Nokogiri::XML(subject.renew_xml_string(renew_item_list)).is_a?(Nokogiri::XML::Document)).to be_truthy
      end

      it 'contains the item id of the item to be renewed' do
        renew_xml = Nokogiri::XML(subject.renew_xml_string(renew_item_list))
        expect(renew_xml.xpath('//myac:itemId', 'myac' => voyager_xml_namespace).first.text).to eq(renew_item_list.first)
        expect(renew_xml.xpath('//myac:itemId', 'myac' => voyager_xml_namespace).last.text).to eq(renew_item_list.last)
      end
    end
  end
end
