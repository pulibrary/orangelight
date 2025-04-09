# frozen_string_literal: true

require 'rails_helper'

# For the rest of the specs, we have our entire example corpus in Solr.
# For these tests we want a very limited Solr corpus to test complex boolean searching in
# a more controlled way.
RSpec.describe 'complex boolean searching', guided_search: true do
  let(:solr_url) do
    ENV['SOLR_SMALL_URL'] || "http://#{ENV['lando_orangelight_small_test_solr_conn_host'] || '127.0.0.1'}:#{ENV['SOLR_TEST_PORT'] || ENV['lando_orangelight_small_test_solr_conn_port'] || 8888}/solr/orangelight-core-small-test"
  end
  let(:solr) { RSolr.connect(url: solr_url) }
  let(:apple_doc) do
    { 'id': ["1"], 'title_display': ['Apples are delicious'] }
  end
  let(:banana_doc) do
    { 'id': ["2"], 'title_display': ['Bananas are yummy'] }
  end
  let(:cantaloupe_doc) do
    { 'id': ["3"], 'title_display': ['Cantaloupes are sweet'] }
  end
  let(:potato) do
    { 'id': ["4"], 'title_display': ['Only potatoes are good'] }
  end
  let(:carrot) do
    { 'id': ["5"], 'title_display': ['Only carrots are good'] }
  end
  let(:potato_and_carrot_doc) do
    { 'id': ["6"], 'title_display': ['Potatoes and Carrots go well together'] }
  end
  let(:date_and_cantaloupe_doc) do
    { 'id': ["7"], 'title_display': ["Dates are squishy and don't go well with cantaloupes"] }
  end
  let(:squishy) do
    { 'id': ["8"], 'title_display': ["Squishy mushrooms and dates"] }
  end

  let(:simple_docs) do
    [
      apple_doc,
      banana_doc,
      cantaloupe_doc,
      potato_and_carrot_doc,
      date_and_cantaloupe_doc,
      squishy
    ]
  end
  around(:all) do |examples|
    solr.update data: '<delete><query>*:*</query></delete>', headers: { 'Content-Type' => 'text/xml' }
    solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    simple_docs.each do |doc|
      solr.add doc
    end
    solr.update data: '<commit/>', headers: { 'Content-Type' => 'text/xml' }
    examples.run
  end

  before do
    stub_holding_locations
    allow(Blacklight.default_index).to receive(:connection).and_return(solr)
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Blacklight::Configuration).to receive(:connection_config).and_return({ adapter: "solr", url: solr_url })
    # rubocop:enable RSpec/AnyInstance
  end

  context 'using guided search' do
    before do
      visit '/guided'
    end
    it 'can find a single entry' do
      fill_in('clause_0_query', with: 'apple')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('1 entry found')
      expect(page).to have_content('1 entry found')
      expect(page).to have_content('Apples are delicious')
    end

    it 'can find entries using OR in a single field', js: true do
      fill_in('clause_0_query', with: 'apple OR banana')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('1 - 2 of 2')
      expect(page).to have_content('1 - 2 of 2')
      expect(page).to have_content('Apples are delicious')
      expect(page).to have_content('Bananas are yummy')
    end

    it 'can find entries using OR across fields' do
      fill_in('clause_0_query', with: 'apple')
      choose(id: 'boolean_operator1_OR')
      select('Title', from: 'clause_1_field')
      fill_in('clause_1_query', with: 'banana')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('1 - 2 of 2')
      expect(page).to have_content('1 - 2 of 2')
      expect(page).to have_content('Apples are delicious')
      expect(page).to have_content('Bananas are yummy')
    end

    it 'can eliminate entries using AND' do
      fill_in('clause_0_query', with: 'apple AND banana')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('No entries found')
    end

    it 'can include entries using AND' do
      fill_in('clause_0_query', with: 'potato AND carrot')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('1 entry found')

      expect(page).to have_content('1 entry found')
      expect(page).to have_content('Potatoes and Carrots go well together')
    end

    it 'can combine OR and implicit AND queries' do
      pending('Fixing advanced search')
      fill_in('clause_0_query', with: 'apple OR squishy')
      # defaults to AND between fields
      select('Title', from: 'clause_1_field')
      # this should be an implicit AND but is being treated as an OR
      fill_in('clause_1_query', with: 'cantaloupe date')
      click_button('advanced-search-submit')
      expect(page).not_to have_content('Squishy mushrooms and dates')
      expect(page.find('.page_entries').text).to eq('1 entry found')
      expect(page).to have_content('1 entry found')
      expect(page).to have_content("Dates are squishy and don't go well with cantaloupes")
    end

    it 'can combine multiple OR queries with an AND in between' do
      # "apple OR squishy" AND "cantaloupe OR date"
      fill_in('clause_0_query', with: 'apple OR squishy')
      select('Title', from: 'clause_1_field')
      fill_in('clause_1_query', with: 'cantaloupe OR date')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('1 - 2 of 2')
    end
  end
  context 'with multiple types of fields' do
    let(:simple_docs) do
      [
        apple_doc,
        banana_doc
      ]
    end
    let(:apple_doc) do
      { 'id': ["1"], 'title_display': ['Apples are delicious'], 'author_display': 'Mister Banana' }
    end
    let(:banana_doc) do
      { 'id': ["2"], 'title_display': ['Bananas are yummy, with co-star Mr. Apple'] }
    end
    before do
      visit '/guided'
    end
    it 'can limit by the field' do
      select('Title', from: 'clause_0_field')
      fill_in('clause_0_query', with: 'apple')
      select('Author', from: 'clause_1_field')
      fill_in('clause_1_query', with: 'banana')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('1 entry found')
      expect(page).to have_content('Apples are delicious')
    end

    it 'can exclude by field' do
      select('Title', from: 'clause_0_field')
      fill_in('clause_0_query', with: 'apple')
      select('Title', from: 'clause_1_field')
      fill_in('clause_1_query', with: 'banana')
      click_button('advanced-search-submit')
      expect(page.find('.page_entries').text).to eq('1 entry found')
      expect(page).to have_content('Bananas are yummy, with co-star Mr. Apple')
    end
  end
end
