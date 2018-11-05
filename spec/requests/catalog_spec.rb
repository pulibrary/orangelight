# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'search requests for the catalog' do
  let(:url) do
    '/catalog?utf8=%E2%9C%93&f1=all_fields&f2=author&f3=title&op2=AND&op3=AND&q1=%22richardson+chamber+players%22&q2&q3&f_inclusive%5Bformat%5D%5B0%5D=Audio&commit=Search'
  end

  it 'parses for multiple format facets in the search parameters' do
    get url

    expect(response.status).to eq(200)
  end
end
