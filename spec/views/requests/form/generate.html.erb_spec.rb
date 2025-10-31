# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'requests/form/generate.html.erb', :requests do
  let(:user) { User.new }
  let(:mfhd_id) { '22699859840006421' }
  let(:holding_data) do
    {
      'location_code': "lewis$stacks", 'location': "Stacks", 'library': "Lewis Library", 'call_number': "QL737.U58C85", 'call_number_browse': "QL737.U58C85", 'items': [{ 'holding_id': "22699859840006421", 'id': "23699859830006421", 'status_at_load': "1", 'barcode': "32101015665811", 'copy_number': "1" }]
    }
  end
  let(:document) { SolrDocument.new }
  let(:location) { JSON.parse(Rails.root.join('spec/fixtures/holding_locations/rare_xr.json').read).with_indifferent_access }
  let(:patron) do
    patron_hash = { "netid" => "foo", "first_name" => "Foo", "last_name" => "Request", "barcode" => "2
2101007797777",
                    "university_id" => "9999999", "patron_group" => "REG", "patron_id" => "99999", "active_email" => "foo
@princeton.edu" }.with_indifferent_access
    Requests::Patron.new(user:, patron_hash:)
  end
  let(:holding) { Requests::Holding.new(mfhd_id:, holding_data:) }
  let(:item) { Requests::Item.new(holding.items.first) }
  let(:first_filtered_requestable) { Requests::Requestable.new(bib: document, location:, item:, holding:, patron:) }
  let(:requestable_list) { [first_filtered_requestable] }
  let(:form) do
    instance_double(Requests::Form, requestable: requestable_list, first_filtered_requestable:, doc: document, system_id: '123', requestable?: true, patron:, eligible_for_library_services?: true, hidden_field_metadata: {}, mfhd: mfhd_id, holdings: { mfhd_id => holding_data }, default_pick_ups: [], ctx: Requests::SolrOpenUrlContext.new(solr_doc: document))
  end
  let(:form_decorator) do
    Requests::FormDecorator.new(
      form,
      controller.view_context,
      Requests::BackToRecordUrl.new(ActionController::Parameters.new(system_id: '123'))
    )
  end

  it 'has delivery options' do
    assign :request, form_decorator
    assign :user, user
    assign :patron, patron
    render
    expect(rendered).to include 'Delivery Options'
  end
end
