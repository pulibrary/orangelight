# frozen_string_literal: true
require 'rails_helper'

RSpec.shared_examples 'shared request type tests' do
  let(:stubbed_questions) do
    { alma_managed?: true, in_process?: false,
      charged?: false, on_order?: false, aeon?: false,
      annex?: false,
      recap?: false, recap_pf?: false, held_at_marquand_library?: false,
      item_data?: false, recap_edd?: false, scsb_in_library_use?: false, item:,
      library_code: 'ABC', eligible_for_library_services?: true,
      marquand_item?: false }
  end
  it 'with a recap physical delivery request' do
    stubbed_questions[:recap?] = true
    stubbed_questions[:item_data?] = true
    stubbed_questions[:holding_library_in_library_only?] = false
    stubbed_questions[:circulates?] = true
    stubbed_questions[:recap_pf?] = false
    expect(router.calculate_services).to eq(recap_physical_services)
  end
  it 'with a recap electronic delivery request' do
    stubbed_questions[:recap?] = true
    stubbed_questions[:item_data?] = true
    stubbed_questions[:recap_edd?] = true
    stubbed_questions[:holding_library_in_library_only?] = false
    stubbed_questions[:circulates?] = false
    stubbed_questions[:recap_pf?] = false
    expect(router.calculate_services).to eq(recap_electronic_services)
  end
  it 'with an annex physical delivery request' do
    stubbed_questions[:annex?] = true
    stubbed_questions[:circulates?] = true
    stubbed_questions[:item_data?] = true
    expect(router.calculate_services).to eq(annex_physical_services)
  end
  it 'with an annex physical delivery request with no item data' do
    stubbed_questions[:annex?] = true
    stubbed_questions[:circulates?] = true
    expect(router.calculate_services).to eq(annex_no_item_services)
  end
  it 'with an annex electronic delivery request' do
    stubbed_questions[:annex?] = true
    stubbed_questions[:circulates?] = false
    stubbed_questions[:item_data?] = true
    expect(router.calculate_services).to eq(annex_electronic_services)
  end
  it 'with an on order request' do
    stubbed_questions[:on_order?] = true
    expect(router.calculate_services).to eq(on_order_services)
  end
  it 'with an in process request' do
    stubbed_questions[:in_process?] = true
    expect(router.calculate_services).to eq(in_process_services)
  end
  it 'with a pick-up service (on shelf) request' do
    stubbed_questions[:circulates?] = true
    expect(router.calculate_services).to eq(on_shelf_services)
  end
  it 'with a digitization request' do
    stubbed_questions[:circulates?] = true
    expect(router.calculate_services).to eq(digitization_services)
  end
  it 'with a resource sharing service request' do
    stubbed_questions[:charged?] = true
    expect(router.calculate_services).to eq(resource_sharing_services)
  end
  it 'with a reading room request' do
    stubbed_questions[:aeon?] = true
    expect(router.calculate_services).to eq(reading_room_services)
  end

  it 'with a marquand in library use request' do
    stubbed_questions[:held_at_marquand_library?] = true
    stubbed_questions[:marquand_item?] = true
    expect(router.calculate_services).to eq(marquand_in_library_services)
  end

  it 'with a marquand in library use page charged item request' do
    stubbed_questions[:held_at_marquand_library?] = true
    stubbed_questions[:marquand_item?] = true
    stubbed_questions[:charged?] = true
    expect(router.calculate_services).to eq(marquand_page_charged_item_services)
  end
end

RSpec.shared_context 'core patron group' do
  let(:recap_physical_services) { ['recap'] }
  let(:recap_electronic_services) { ['recap_edd'] }
  # Should we expect this to include 'on_shelf_edd' since annex items are not considered 'on_shelf'?
  let(:annex_physical_services) { ['annex', 'on_shelf_edd'] }
  let(:annex_no_item_services) { ['annex_no_items', 'on_shelf_edd'] }
  # Should not have 'anex' since it does not circulate
  let(:annex_electronic_services) { ['annex', 'on_shelf_edd'] }
  let(:on_order_services) { ['on_order'] }
  let(:in_process_services) { ['in_process'] }
  # Any on_shelf_eligible item will also be on_shelf_edd eligible
  let(:on_shelf_services) { ['on_shelf_edd', 'on_shelf'] }
  let(:digitization_services) { ['on_shelf_edd', 'on_shelf'] }
  let(:resource_sharing_services) { ['ill'] }
  let(:reading_room_services) { ['aeon'] }
  let(:marquand_in_library_services) { ['marquand_in_library', 'marquand_edd'] }
  let(:marquand_page_charged_item_services) { ['marquand_page_charged_item'] }
end

RSpec.shared_context 'affiliate and guest patron group' do
  let(:recap_physical_services) { ['recap'] }
  let(:recap_electronic_services) { ['recap_edd'] }
  let(:annex_physical_services) { ['annex'] }
  let(:annex_no_item_services) { ['annex_no_items'] }
  let(:annex_electronic_services) { ['annex'] }
  let(:on_order_services) { [] }
  let(:in_process_services) { [] }
  let(:on_shelf_services) { [] }
  let(:digitization_services) { [] }
  let(:resource_sharing_services) { [] }
  let(:reading_room_services) { ['aeon'] }
  let(:marquand_in_library_services) { [] }
  let(:marquand_page_charged_item_services) { ['marquand_page_charged_item'] }
end

RSpec.shared_context 'shared patron setup' do
  let(:user) { FactoryBot.create(:user) }
  let(:patron) do
    Requests::Patron.new(user:, patron_hash: valid_patron)
  end
  let(:item) { {} }
  let(:requestable) { instance_double(Requests::Requestable, stubbed_questions) }
  let(:router) { described_class.new(requestable:, patron:) }
end

RSpec.shared_context 'cas user' do
  let(:user) { FactoryBot.create(:user) }
end

RSpec.shared_context 'alma user' do
  let(:user) { FactoryBot.create(:alma_patron) }
end

RSpec.describe Requests::Router do
  context 'with a user in group P' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "P" }.with_indifferent_access }
    include_context 'cas user'
    include_context 'shared patron setup'
    include_context 'core patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group GRAD' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "GRAD" }.with_indifferent_access }
    include_context 'cas user'
    include_context 'shared patron setup'
    include_context 'core patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group REG' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "REG" }.with_indifferent_access }
    include_context 'cas user'
    include_context 'shared patron setup'
    include_context 'core patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group SENR' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "SENR" }.with_indifferent_access }
    include_context 'cas user'
    include_context 'shared patron setup'
    include_context 'core patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group UGRD' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "UGRD" }.with_indifferent_access }
    include_context 'cas user'
    include_context 'shared patron setup'
    include_context 'core patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group SUM' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "SUM" }.with_indifferent_access }
    include_context 'cas user'
    include_context 'shared patron setup'
    include_context 'core patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group Affiliate' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "Affiliate" }.with_indifferent_access }
    include_context 'alma user'
    include_context 'shared patron setup'
    include_context 'affiliate and guest patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group Affiliate-P' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "Affiliate-P" }.with_indifferent_access }
    include_context 'alma user'
    include_context 'shared patron setup'
    include_context 'affiliate and guest patron group'
    it_behaves_like 'shared request type tests'
  end
  context 'with a user in group GST' do
    let(:valid_patron) { { "netid" => "foo", "patron_group" => "GST" }.with_indifferent_access }
    include_context 'alma user'
    include_context 'shared patron setup'
    include_context 'affiliate and guest patron group'
    it_behaves_like 'shared request type tests'
  end
end
