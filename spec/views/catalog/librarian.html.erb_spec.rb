# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/librarian_view' do
  context 'when the MARC data cannot be generated for a Solr Document' do
    let(:document) { TestSolrDocument.new }

    before do
      class TestSolrDocument
        def id
          'test-id'
        end

        def to_marc; end
      end

      assign(:document, document)
      render template: 'catalog/librarian_view.html.erb'
    end

    after do
      ActiveSupport::Dependencies.remove_constant('TestSolrDocument')
    end

    it 'flashes an error message' do
      expect(rendered).to include 'No MARC data found.'
    end
  end
end
