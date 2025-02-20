# frozen_string_literal: true

require 'rails_helper'

describe 'citation', citation: true do
  before do
    allow_any_instance_of(CatalogController).to receive(:agent_is_crawler?).and_return(false)
  end
  context 'with an alma marcxml record' do
    let(:bibid) { '9979948663506421' }
    let(:marc_xml) { File.read(File.join(File.dirname(__FILE__), '..', 'fixtures', 'bibdata', "#{bibid}.xml")) }

    before do
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}").to_return(
        status: 200,
        body: marc_xml
      )
    end
    it 'will render successfully even if there is not a subfield a' do
      visit '/catalog/9979948663506421/citation'
      expect(current_url).to include '/catalog/9979948663506421/citation'
      expect(page.status_code).to eq 200
    end

    it 'renders the citation' do
      visit '/catalog/9979948663506421/citation'
      expect(page.body).to include('Henderson, W. J, et al.')
    end
  end

  context 'with a scsb record' do
    let(:bibid) { 'SCSB-2635660' }
    before do
      stub_request(:get, "#{Requests.config['bibdata_base']}/bibliographic/#{bibid}")
        .to_return(status: 404)
    end

    it 'renders the citation' do
      visit "/catalog/#{bibid}/citation"
      expect(current_url).to include("/catalog/#{bibid}/citation")
      expect(page.body).to include('Juan José. <i>El Entenado</i>. 1a edición, Destino, 1988.')
    end
  end
end
