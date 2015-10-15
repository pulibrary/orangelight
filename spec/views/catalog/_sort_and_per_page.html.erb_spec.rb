require 'rails_helper'

RSpec.describe "catalog/_sort_and_per_page" do
  let(:blacklight_config) do
    CatalogController.new.blacklight_config
  end

  before do
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    assign(:response, double("SolrResponse", limit_value: 1))
    stub_template "catalog/_paginate_compact.html.erb" => "paginate_compact"
    stub_template "catalog/_sort_widget.html.erb" => "sort_widget"
    stub_template "catalog/_per_page_widget.html.erb" => "per_page_widget"
    stub_template "catalog/_view_type_group.html.erb" => "view_type_group"
    render
  end

  it "renders the bookmark all tool" do
    expect(view).to render_template "catalog/_bookmark_all"
  end
end
