# frozen_string_literal: true

require 'rails_helper'
require 'faraday'

GOOGLEBOT_USER_AGENT = "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.110 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"

describe 'robot user-agents' do
  context 'when visiting search results page' do
    it 'does not create a search entry in the database' do
      expect do
        get '/catalog?search_field=all_fields&q=flying+fish',
            headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      end.not_to change { Search.count }
    end
    it 'does not include availability information' do
      stub_holding_locations
      get '/catalog?search_field=all_fields&q=art',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response.body).not_to include('data-availability-record="true"')
    end
  end
  context 'when visiting call number browse' do
    it 'does not include availability information' do
      stub_holding_locations
      get '/browse/call_numbers?search_field=browse_cn&q=HQ',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response.body).not_to include('data-availability-record="true"')
    end
  end

  context 'when visiting a show page' do
    it 'does not show a viewer' do
      get '/catalog/99125203099306421',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response.body).not_to include('class="document-viewers"')
    end
  end

  context 'when exporting as .endnote' do
    it 'does not retrieve marc data from bibdata' do
      document = SolrDocument.new(id: '99125203099306421')
      allow(SolrDocument).to receive(:new).and_return(document)
      allow(document).to receive(:to_marc)
      get '/catalog/99125203099306421.endnote',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(document).not_to have_received(:to_marc)
    end
  end

  context 'when viewing citations', citation: true do
    it 'does not retrieve marc data from bibdata' do
      document = SolrDocument.new(id: '99125203099306421')
      allow(SolrDocument).to receive(:new).and_return(document)
      allow(document).to receive(:to_marc)
      get '/catalog/99125203099306421/citation',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(document).not_to have_received(:to_marc)
    end
  end

  context 'when visiting a staff view page' do
    it 'does not retrieve marc data from bibdata' do
      document = SolrDocument.new(id: '99125203099306421')
      allow(SolrDocument).to receive(:new).and_return(document)
      allow(document).to receive(:to_marc)
      get '/catalog/99125203099306421/staff_view',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(document).not_to have_received(:to_marc)
    end
  end
end

describe 'empty user-agents' do
  context 'when visiting search results page' do
    it 'does not create a search entry in the database' do
      expect do
        get '/catalog?search_field=all_fields&q=flying+fish'
      end.not_to change { Search.count }
    end
  end
end
