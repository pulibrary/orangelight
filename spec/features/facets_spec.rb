require 'rails_helper'

context "with facets rendered" do
  it "renders only a subset of all the facets on the homepage" do
    visit "/catalog"
    home_facets = page.all('.facet_limit').length
    visit "/catalog?search_field=all_fields"
    search_facets = page.all('.facet_limit').length
    expect(home_facets).to be < search_facets
  end
end

context "with advanced limits" do
  it "will render when clicked from the record" do
    visit  "/catalog/3"
    click_link "Advanced Search"
    click_link "Clear form"
  end
end
