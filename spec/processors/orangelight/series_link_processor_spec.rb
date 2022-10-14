# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Orangelight::SeriesLinkProcessor do
  let(:values) { ['Offenbach, Jacques, 1819-1880. Operas. Selections (Bourg)', 'Collection Archive'] }
  let(:config) { Blacklight::Configuration::Field.new(key: 'field', series_link: true) }
  let(:document) { SolrDocument.new({ 'more_in_this_series_t': ['Offenbach, Jacques, 1819-1880. Operas. Selections (Bourg)'] }) }
  let(:options) do
    { context: 'show' }
  end
  let(:stack) { [Blacklight::Rendering::Terminator] } # Don't run any other processors after this
  let(:processor) { described_class.new(values, config, document, {}, options, stack) }
  let(:rendered) { processor.render }

  it 'adds links if they also appear in the more_in_this_series_t field' do
    expect(rendered.first).to eq('Offenbach, Jacques, 1819-1880. Operas. Selections (Bourg) '\
                                 '<a class="more-in-series" data-toggle="tooltip" '\
                                 'data-original-title="More in series: Offenbach, Jacques, 1819-1880. Operas. Selections (Bourg)" '\
                                 'title="" dir="ltr" href="/catalog?q1=Offenbach%2C+Jacques%2C+1819-1880.+Operas.+Selections+Bourg&amp;f1=in_series&amp;search_field=advanced">'\
                                 '[More in this series]</a>')
  end

  it "does not add links if they don't appear in the more_in_this_series_t field" do
    expect(rendered.second).to eq('Collection Archive')
  end

  context 'empty more_in_this_series_t field' do
    let(:document) { SolrDocument.new }
    it 'does not add links' do
      expect(rendered.first).to eq('Offenbach, Jacques, 1819-1880. Operas. Selections (Bourg)')
    end
  end

  context 'more_in_this_series_t contains a shorter version of the series title' do
    let(:document) { SolrDocument.new({ 'more_in_this_series_t': ['Offenbach, Jacques, 1819-1880. Operas'] }) }
    it 'adds the link' do
      expect(rendered.first).to eq('Offenbach, Jacques, 1819-1880. Operas. Selections (Bourg) '\
      '<a class="more-in-series" data-toggle="tooltip" '\
      'data-original-title="More in series: Offenbach, Jacques, 1819-1880. Operas. Selections (Bourg)" '\
      'title="" dir="ltr" href="/catalog?q1=Offenbach%2C+Jacques%2C+1819-1880.+Operas&amp;f1=in_series&amp;search_field=advanced">'\
      '[More in this series]</a>')
    end
  end
end
