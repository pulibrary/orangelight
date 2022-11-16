# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightDynamicSitemap::Sitemap do
  let(:sitemap) { described_class.new }
  before do
    allow(sitemap).to receive(:max_documents).and_return(22_000_000)
  end
  context 'when using our configuration' do
    it 'puts documents into a smaller buckets than the default' do
      expect(sitemap.send(:exponent)).to eq(4)
    end
  end
  context 'when using the upstream default value' do
    before do
      allow(BlacklightDynamicSitemap::Engine.config).to receive(:minimum_average_chunk).and_return(10_000)
    end
    it 'puts documents into buckets that are too big' do
      expect(sitemap.send(:exponent)).to eq(3)
    end
  end
end
