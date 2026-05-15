# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'language tags' do
  it 'includes language tag for publication info on the search results page' do
    stub_holding_locations

    # search for: 華番和合通書
    get 'http://localhost:3000/catalog?search_field=all_fields&q=%E8%8F%AF%E7%95%AA%E5%92%8C%E5%90%88%E9%80%9A%E6%9B%B8'
    parsed = Nokogiri::HTML(response.body)
    expect(parsed.xpath('//*[@lang="zh" and contains(text(), "清咸豐2年")]')).to be_present
  end
  it 'includes language tag for Romanized publication info on the search results page' do
    stub_holding_locations

    # search for: 華番和合通書
    get 'http://localhost:3000/catalog?search_field=all_fields&q=%E8%8F%AF%E7%95%AA%E5%92%8C%E5%90%88%E9%80%9A%E6%9B%B8'
    parsed = Nokogiri::HTML(response.body)
    expect(parsed.xpath('//*[@lang="zh-Latn" and contains(text(), "Qing Xianfeng 2 nian")]')).to be_present
  end
end
