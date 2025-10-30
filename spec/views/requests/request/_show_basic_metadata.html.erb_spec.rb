# frozen_string_literal: true
require 'rails_helper'
RSpec.describe '_show_basic_metadata partial', :requests do
  let(:view_context) do
    controller = Requests::FormController.new
    controller.action_name = 'form'
    controller.request = ActionDispatch::Request.empty
    controller.view_context
  end
  it 'displays the date' do
    document = SolrDocument.new pub_date_display: '1985'
    rendered = view_context.render partial: 'show_basic_metadata', locals: { document: }
    expect(rendered).to include '1985'
  end
  it 'does not display the date if it is 9999' do
    document = SolrDocument.new pub_date_display: '9999'
    rendered = view_context.render partial: 'show_basic_metadata', locals: { document: }
    expect(rendered).not_to include '9999'
  end
  it 'displays the author' do
    document = SolrDocument.new author_citation_display: ['Shoberg, Lore']
    rendered = view_context.render partial: 'show_basic_metadata', locals: { document: }
    expect(rendered).to include 'Author/Artist'
    expect(rendered).to include 'Shoberg, Lore'
  end
  it 'does not display the author if no author is present' do
    document = SolrDocument.new author_citation_display: []
    rendered = view_context.render partial: 'show_basic_metadata', locals: { document: }
    expect(rendered).not_to include 'Author/Artist'
  end
end
