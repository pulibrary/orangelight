require "rails_helper"

describe "404 page" do
  it "is customized" do
    # Haven't been able to get the "show instead of exceptions" thing working in tests, but this at least makes sure the page can render correctly.
    visit "/404"
    expect(page.status_code).to eq 404
    expect(page).to have_content("The page you were looking for doesn't exist")
  end
end
