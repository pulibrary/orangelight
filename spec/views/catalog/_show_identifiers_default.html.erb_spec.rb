require 'rails_helper'

RSpec.describe 'catalog/_show_identifiers_default.html.erb' do
  let(:document) { SolrDocument.new(properties) }
  let(:properties) do
    {
      'lccn_s' => ['2001522653'],
      'isbn_s' => ['9781400827824'],
      'oclc_s' => %w(19590730 301985443)
    }
  end
  before do
    render partial: 'catalog/show_identifiers_default', locals: { document: document }
  end
  it 'displays a meta tag for each isbn' do
    expect(rendered).to have_selector("meta[property='isbn'][itemprop='isbn'][content='9781400827824']")
  end
  it 'displays a meta tag for each oclc' do
    expect(rendered).to have_selector("meta[property='http://purl.org/library/oclcnum'][content='19590730']")
    expect(rendered).to have_selector("meta[property='http://purl.org/library/oclcnum'][content='301985443']")
  end

  context 'when there is no identifier' do
    let(:properties) { {} }
    it 'does not display anything' do
      expect(rendered).not_to have_selector('meta')
    end
  end
end
