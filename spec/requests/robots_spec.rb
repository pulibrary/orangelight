# frozen_string_literal: true

require 'rails_helper'
require 'faraday'

GOOGLEBOT_USER_AGENT = "Mozilla/5.0 (Linux; Android 6.0.1; Nexus 5X Build/MMB29P) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.5845.110 Mobile Safari/537.36 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)"
GPTBOT_USER_AGENT = "Mozilla/5.0 AppleWebKit/537.36 (KHTML, like Gecko; compatible; GPTBot/1.0; +https://openai.com/gptbot)"

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
  context 'when visiting a search result with many facet values' do
    it 'returns 414 URI Too Long' do
      get '/?f[access_facet][]=In+the+Library&f[format][]=Journal&f[geographic_facet][]=Alsace+%28France%29&' \
          'f[language_facet][]=French&f[publication_place_facet][]=France&f[subject_topic_facet][]=Antiquities',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response).to have_http_status :uri_too_long
    end

    it 'returns 414 URI Too Long when all the facet values are for the same facet' do
      get '/?f[language_facet][]=French&f[language_facet][]=German&f[language_facet][]=Spanish&' \
          'f[language_facet][]=Italian&f[language_facet][]=Portuguese&f[language_facet][]=Dutch',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response).to have_http_status :uri_too_long
    end

    it 'does not make any calls to solr' do
      # rubocop:disable RSpec/AnyInstance
      expect_any_instance_of(RSolr::Client).not_to receive(:send_and_receive)
      # rubocop:enable RSpec/AnyInstance
      get '/?f[access_facet][]=In+the+Library&f[format][]=Journal&f[geographic_facet][]=Alsace+%28France%29&' \
          'f[language_facet][]=French&f[publication_place_facet][]=France&f[subject_topic_facet][]=Antiquities',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
    end
  end
  context 'when visiting a search result with only a few facet values' do
    it 'returns 200 ok' do
      get '/?f[access_facet][]=In+the+Library&f[format][]=Journal&f[geographic_facet][]=Alsace+%28France%29',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response).to have_http_status :ok
    end
  end

  context 'when visiting call number browse', browse: true do
    it 'does not include availability information' do
      stub_holding_locations
      get '/browse/call_numbers?search_field=browse_cn&q=HQ',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response.body).not_to include('data-availability-record="true"')
    end
  end

  context 'when visiting a show page' do
    it 'does not show a viewer', :viewer do
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

describe 'gptbot' do
  context 'when visiting search results page' do
    it 'does not create a search entry in the database' do
      expect do
        get '/catalog?search_field=all_fields&q=flying+fish',
            headers: { "HTTP_USER_AGENT" => GPTBOT_USER_AGENT }
      end.not_to change { Search.count }
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

  context 'when visiting a search result with many facet values' do
    it 'returns 414 URI Too Long' do
      get '/?f[access_facet][]=In+the+Library&f[format][]=Journal&f[geographic_facet][]=Alsace+%28France%29&' \
          'f[language_facet][]=French&f[publication_place_facet][]=France&f[subject_topic_facet][]=Antiquities',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
      expect(response).to have_http_status :uri_too_long
    end

    it 'does not make any calls to solr' do
      # rubocop:disable RSpec/AnyInstance
      expect_any_instance_of(RSolr::Client).not_to receive(:send_and_receive)
      # rubocop:enable RSpec/AnyInstance
      get '/?f[access_facet][]=In+the+Library&f[format][]=Journal&f[geographic_facet][]=Alsace+%28France%29&' \
          'f[language_facet][]=French&f[publication_place_facet][]=France&f[subject_topic_facet][]=Antiquities',
          headers: { "HTTP_USER_AGENT" => GOOGLEBOT_USER_AGENT }
    end
  end
end
