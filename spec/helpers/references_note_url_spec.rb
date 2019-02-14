# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper do
  describe '#references_url' do
    let(:reference_note) { 'Special reference' }
    let(:url) { 'http://google.com' }
    let(:reference_with_url) { "#{reference_note} #{url}" }
    let(:reference_without_url) { 'Unlinked reference' }
    let(:reference_field) { [reference_with_url, reference_without_url] }
    let(:document) { { field => reference_field } }
    let(:field) { 'same_as_in_document' }
    let(:args_object) { { field: field, document: document } }

    it 'converts reference notes ending with a url to an html link' do
      expect(references_url(args_object)).to include(link_to(reference_note, url, target: '_blank'))
    end

    it 'keeps reference notes without url the same' do
      expect(references_url(args_object)).to include(reference_without_url)
    end
  end
end
