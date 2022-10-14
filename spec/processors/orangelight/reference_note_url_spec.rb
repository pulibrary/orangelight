# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::ReferenceNoteUrlProcessor do
  include ActionView::Helpers::UrlHelper

  describe '#process' do
    let(:reference_note) { 'Special reference' }
    let(:url) { 'http://google.com' }
    let(:reference_with_url) { "#{reference_note} #{url}" }
    let(:reference_without_url) { 'Unlinked reference' }
    let(:values) { [reference_with_url, reference_without_url] }
    let(:config) { Blacklight::Configuration::Field.new(key: 'field', references_url: true) }
    let(:document) { SolrDocument.new }
    let(:options) do
      { context: 'show' }
    end
    let(:stack) { [Blacklight::Rendering::Terminator] } # Don't run any other processors after this
    let(:processor) { described_class.new(values, config, document, {}, options, stack) }

    it 'converts reference notes ending with a url to an html link' do
      expect(processor.render).to include(link_to(reference_note, url, target: '_blank', rel: 'noopener'))
    end

    it 'keeps reference notes without url the same' do
      expect(processor.render).to include(reference_without_url)
    end
  end
end
