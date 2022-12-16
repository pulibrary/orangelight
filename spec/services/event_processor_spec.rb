# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcessor do
  subject(:processor) { described_class.new(event) }

  let(:resource) { Blacklight.default_index.connection.get('select', params:) }
  let(:params) { { q: "id:#{RSolr.solr_escape(id)}" } }
  let(:id) { 'objectid' }
  let(:bulk) { 'false' }
  let(:title) { 'title' }
  let(:event) do
    {
      'id' => id,
      'event' => type,
      'bulk' => bulk,
      'doc' => blacklight_document
    }
  end
  let(:blacklight_document) do
    {
      'id' => id,
      'title_display' => title
    }
  end

  context 'when given an unknown event' do
    let(:type) { 'UNKNOWNEVENT' }

    it 'returns false' do
      expect(processor.process).to eq false
    end
  end

  context 'when given a creation event with an invalid document' do
    let(:type) { 'CREATED' }
    let(:blacklight_document) { { 'title_display' => title } }

    it 'returns false' do
      expect(processor.process).to eq false
    end
  end

  context 'when given a creation event with an valid document' do
    let(:type) { 'CREATED' }

    it 'adds the blacklight document' do
      expect(processor.process).to eq true
      params = { q: "id:#{RSolr.solr_escape(id)}" }
      resource = Blacklight.default_index.connection.get('select', params:)
      expect(resource['response']['docs'].first['id']).to eq(id)
    end
  end

  context 'when given an update event' do
    let(:type) { 'UPDATED' }
    let(:title) { 'updated title' }

    it 'updates that resource' do
      expect(processor.process).to eq true
      expect(resource['response']['docs'].first['title_display']).to eq(title)
    end
  end

  context 'when given a delete event' do
    let(:type) { 'DELETED' }

    it 'deletes that resource' do
      expect(processor.process).to eq true
      expect(resource['response']['docs'].length).to eq(0)
    end
  end

  context 'when given an update event as part of bulk process' do
    let(:type) { 'UPDATED' }
    let(:title) { 'updated title' }
    let(:bulk) { 'true' }
    let(:connection) { instance_double(RSolr::Client) }

    before do
      allow(Blacklight.default_index).to receive(:connection).and_return(connection)
      allow(connection).to receive(:update)
      allow(connection).to receive(:commit)
    end

    it 'does not fire a commit command' do
      processor.process
      expect(connection).to have_received(:update)
      expect(connection).not_to have_received(:commit)
    end
  end

  context 'when given a delete event as part of a bulk process' do
    let(:type) { 'DELETED' }
    let(:bulk) { 'true' }
    let(:connection) { instance_double(RSolr::Client) }

    before do
      allow(Blacklight.default_index).to receive(:connection).and_return(connection)
      allow(connection).to receive(:delete_by_query)
      allow(connection).to receive(:commit)
    end

    it 'does not fire a commit command' do
      processor.process
      expect(connection).to have_received(:delete_by_query)
      expect(connection).not_to have_received(:commit)
    end
  end
end
