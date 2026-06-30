# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "browse_pagination partial", type: :view do
  describe "#previous_button" do
    context "on first page (no previous)" do
      it "renders disabled state with aria-disabled attribute" do
        assign :is_first, true
        assign :page_link, '123'
        rendered = render 'orangelight/browsables/browse_pagination'
        parsed = Nokogiri::HTML::DocumentFragment.parse rendered

        expect(parsed.css('a').attribute('aria-disabled').value).to eq 'true'
      end
    end
  end
end
