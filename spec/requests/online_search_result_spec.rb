# frozen_string_literal: true
require 'rails_helper'

describe 'Online search result' do
  it 'does not include a message about missing holdings' do
    get '/catalog?search_field=all_fields&q=+Anuario+estadistico+de+la+Republica+Argentina'
    parsed = Nokogiri::HTML response.body

    expect(parsed.text).to include '1 entry found'
    expect(parsed.text).not_to include 'No holdings available for this record'
    expect(parsed.text).not_to include I18n.t('blacklight.holdings.search_missing')
  end
end
