require 'rails_helper'

context 'clicking facet limits with values in the search bar' do
  it 'includes search input in result, url is escaped', js: true do
    visit '/catalog'
    select('Title starts with', from: 'Search in')
    fill_in('Search...', with: 'The & this')
    click_link 'In the Library'
    expect(current_url).to include('q=The%20%26%20this', 'search_field=left_anchor')
  end

  it 'only includes the url parameters once when query is unchanged', js: true do
    visit '/?f[access_facet][]=In+the+Library&q=The&search_field=left_anchor'
    click_link 'Book'
    expect(current_url.scan(/q=The/).size).to eq 1
  end

  it 'updates url parameters if search input is updated', js: true do
    visit '/?f[access_facet][]=In+the+Library&q=The&search_field=left_anchor'
    fill_in('Search...', with: 'next')
    click_link 'Book'
    expect(current_url).not_to include('q=The')
    expect(current_url).to include('q=next')
  end
end
