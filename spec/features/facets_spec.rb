require 'rails_helper'

describe "Facets rendered" do
  it "Only a subset of all the facets render on the homepage" do
    visit  "/catalog"
    home_facets = page.all('.facet_limit').length
    visit "/catalog?search_field=all_fields"
    search_facets = page.all('.facet_limit').length
    expect(home_facets).to be < search_facets
  end
end

describe "Advanced limits" do
  it "will render when clicked from the record" do
    visit  "/catalog/3"
    click_link "Advanced Search"
    click_link "Clear form"
  end
end
