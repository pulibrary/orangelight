# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bookmarks::ToolsComponent, type: :component do
  it "includes CSV" do
    with_controller_class BookmarksController do
      documents = []
      url_opts = { "f" => { "id" => ["99122643653506421", "99127972072106421", "99122304923506421"] } }
      rendered = render_inline(described_class.new(documents:, url_opts:))
      expect(rendered.text).to include 'CSV'
    end
  end
end
