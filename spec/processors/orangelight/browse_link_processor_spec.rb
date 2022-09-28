# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::BrowseLinkProcessor do
  let(:values) { ['1'] }
  let(:config) { Blacklight::Configuration::Field.new(key: 'field', browse_link: :name) }
  let(:document) { SolrDocument.new }
  let(:options) do
    { context: 'show' }
  end
  let(:stack) { [Blacklight::Rendering::Terminator] } # Don't run any other processors after this
  let(:processor) { described_class.new(values, config, document, {}, options, stack) }
  let(:rendered) { processor.render }

  it 'adds search and browse links' do
    expect(rendered).to eq [
      '<a class="search-name" data-toggle="tooltip" data-original-title="Search: 1" title="" href="/?f[author_s][]=1">1</a> '\
      '<a class="browse-name" data-toggle="tooltip" data-original-title="Browse: 1" title="" dir="ltr" href="/browse/names?q=1">[Browse]</a>'
    ]
  end
  context 'name-title field' do
    let(:config) { Blacklight::Configuration::Field.new(key: 'field', browse_link: :name_title) }
    context 'empty name_title_browse_s field' do
      it 'does not add a name-title search or browse link' do
        expect(rendered).to eq ['1']
      end
    end
    context 'value not in name_title_browse_s field' do
      let(:document) { SolrDocument.new({ name_title_browse_s: ['dogs', 'cats'] }) }
      it 'does not add a name-title search or browse link' do
        expect(rendered).to eq ['1']
      end
    end
    context 'value in name_title_browse_s field' do
      let(:document) { SolrDocument.new({ name_title_browse_s: ['1'] }) }
      it 'adds name-title search and browse links' do
        expect(rendered).to eq [
          '<a class="search-name-title" data-toggle="tooltip" data-original-title="Search: 1" title="" href="/?f[name_title_browse_s][]=1">1</a> '\
            '<a class="browse-name-title" data-toggle="tooltip" data-original-title="Browse: 1" title="" dir="ltr" href="/browse/name_titles?q=1">[Browse]</a>'
        ]
      end
    end
  end
end
