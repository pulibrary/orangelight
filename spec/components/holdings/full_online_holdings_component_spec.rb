# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Holdings::FullOnlineHoldingsComponent, type: :component do
  it 'generates electronic access links for a catalog record given doc_electronic_access' do
    adapter = instance_double(HoldingRequestsAdapter, {
                                doc_electronic_access: { 'http://gateway.proquest.com/url': ['gateway.proquest.com'], 'http://arks.princeton.edu/ark:/88435/dsp0141687h654': ['DataSpace', 'Citation only'] },
                                electronic_portfolios: [],
                                sibling_electronic_portfolios: []
                              })
    rendered = render_inline(described_class.new(adapter))
    proquest_link = rendered.css('[href="http://gateway.proquest.com/url"]')
    expect(proquest_link.text.strip).to eq 'gateway.proquest.com'
    expect(proquest_link.css('i[class="fa fa-external-link new-tab-icon-padding"][aria-label="opens in new tab"][role="img"]')).to be_present

    dataspace_link = rendered.css('[href="http://arks.princeton.edu/ark:/88435/dsp0141687h654"]')
    expect(dataspace_link.text).to include 'Citation only:'
    expect(dataspace_link.text).to include 'DataSpace'
    expect(dataspace_link.css('i[class="fa fa-external-link new-tab-icon-padding"][aria-label="opens in new tab"][role="img"]')).to be_present
  end

  it 'ensures that the "|" character does not get encoded twice' do
    adapter = instance_double(HoldingRequestsAdapter, {
                                doc_electronic_access: { 'http://go.galegroup.com/ps/i.do?id=GALE%257C9781440840869&v=2.1&u=prin77918&it=etoc&p=GVRL&sw=w' => ['go.galegroup.com'] },
                                electronic_portfolios: [],
                                sibling_electronic_portfolios: []
                              })
    rendered = render_inline(described_class.new(adapter))
    expect(rendered.css('a').attribute('href').value).to include 'http://go.galegroup.com/ps/i.do?id=GALE%7C9781440840869'
  end

  it 'displays the public note properly' do
    adapter = instance_double(HoldingRequestsAdapter, {
                                doc_electronic_access: {},
                                electronic_portfolios: [
                                  { 'desc' => 'Description',
                                    'title' => 'Title',
                                    'url' => 'https://princeton.edu/great-resource',
                                    'start' => '1980',
                                    'end' => '2015',
                                    'notes' => ['First note', 'Second note'] }
                                ],
                                sibling_electronic_portfolios: []
                              })
    parsed = render_inline(described_class.new(adapter))

    list_item = parsed.css('li').first
    expect(list_item['class'].strip).to eq 'electronic-access lux'

    link = list_item.at_css 'a'
    expect(link['target']).to eq '_blank'
    expect(link['rel']).to eq 'noopener'
    expect(link['class']).to eq 'electronic-access-link'
    expect(link['href']).to eq 'https://princeton.edu/great-resource'
    expect(link.text.strip).to eq '1980 - 2015: Title'

    show_more = list_item.at_css 'lux-show-more'
    expect(show_more.text).to eq 'Description'

    expect(list_item.text).to include '(First note, Second note)'
  end
end
