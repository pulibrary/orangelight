# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Orangelight::HighlightProcessor do
  let(:values) { ['The lives of <em>Black</em> and Latino <em>teenagers</em> in a low-income :'] }
  let(:config) { Blacklight::Configuration::Field.new(key: 'field', mark_as_safe: true) }
  let(:document) { SolrDocument.new }
  let(:options) do
    { context: 'show' }
  end
  let(:stack) { [Blacklight::Rendering::Terminator] } # Don't run any other processors after this
  let(:processor) { described_class.new(values, config, document, {}, options, stack) }
  let(:rendered) { processor.render }

  it "adds the class to the em tag" do
    node = Capybara::Node::Simple.new(rendered[0])
    expect(node).to have_selector('.highlight-query')
    expect(rendered).to include('The lives of <em class="highlight-query">Black</em> and Latino <em class="highlight-query">teenagers</em> in a low-income :')
  end
end
