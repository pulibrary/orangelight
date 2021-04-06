# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "catalog/librarian_view.html.erb" do
  context "when given an Alma marc source with AVA fields" do
    it "displays the AVA fields" do
      allow(view).to receive(:params).and_return(id: "9922486553506421")
      stub_request(:get, "https://bibdata-staging.princeton.edu/bibliographic/9922486553506421")
        .to_return(status: 200, body: File.open(Rails.root.join("spec", "fixtures", "alma", "9922486553506421_marc.xml")), headers: {})

      render

      expect(rendered).to have_selector ".subfields", text: "19990423000000.0"
      expect(rendered).to have_selector ".tag", text: "AVA"
    end
  end
end
