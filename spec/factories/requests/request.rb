# frozen_string_literal: true
require 'factory_bot'

FactoryBot.define do
  factory :request_no_items, class: 'Requests::Request' do
    system_id { '9944928463506421' }
    mfhd { '22490610730006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  #  I think this is a problem record
  factory :request_on_order, class: 'Requests::Request' do
    system_id { '9939075533506421' }
    mfhd { '22675089420006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :request_thesis, class: 'Requests::Request' do
    system_id { "dsp019c67wp402" }
    mfhd { 'thesis' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :request_numismatics, class: 'Requests::Request' do
    system_id { "coin-1167" }
    mfhd { 'numismatics' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :request_paging_available, class: 'Requests::Request' do
    system_id { '9960093633506421' }
    mfhd { '2272418840006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :request_paging_available_barcode_patron, class: 'Requests::Request' do
    system_id { '9960093633506421' }
    mfhd { '2272418840006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :request_paging_available_unauthenticated_patron, class: 'Requests::Request' do
    system_id { '9960093633506421' }
    mfhd { '2272418840006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  # missing item
  factory :request_missing_item, class: 'Requests::Request' do
    system_id { '9915486663506421' }
    mfhd { '22495908770006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :request_on_shelf, class: 'Requests::Request' do
    system_id { '9912140633506421' }
    mfhd { '22722595360006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :aeon_eal_alma_item, class: 'Requests::Request' do
    system_id { '9977213233506421' }
    mfhd { '22707739710006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :aeon_w_barcode, class: 'Requests::Request' do
    system_id { '9995944353506421' }
    mfhd { '22500750240006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :aeon_w_long_title, class: 'Requests::Request' do
    system_id { '9929908463506421' }
    mfhd { '22656754050006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :aeon_no_item_record, class: 'Requests::Request' do
    system_id { '9925358453506421' }
    mfhd { '22615926030006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron) }
  end

  factory :aeon_rbsc_alma_enumerated, class: 'Requests::Request' do
    system_id { '996160863506421' }
    mfhd_id { '22563389780006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :aeon_rbsc_enumerated, class: 'Requests::Request' do
    system_id { '9967949663506421' }
    mfhd_id { '22677203260006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :aeon_marquand, class: 'Requests::Request' do
    system_id { '9979153343506421' }
    mfhd_id { '22742463930006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :aeon_mudd, class: 'Requests::Request' do
    system_id { '9960234393506421' }
    mfhd_id { '22524308350006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :aeon_mudd_barcode_patron, class: 'Requests::Request' do
    system_id { '9960234393506421' }
    mfhd_id { '22524308350006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :aeon_mudd_unauthenticated_patron, class: 'Requests::Request' do
    system_id { '9960234393506421' }
    mfhd_id { '22524308350006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :missing_item, class: 'Requests::Request' do
    system_id { '9915486663506421' }
    mfhd_id { '22495908770006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  ## I think this item is no longer charged
  factory :request_with_items_charged, class: 'Requests::Request' do
    system_id { '9913891213506421' }
    mfhd_id { '22739043950006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :request_with_items_charged_barcode_patron, class: 'Requests::Request' do
    system_id { '9913891213506421' }
    mfhd_id { '22739043950006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :request_with_items_charged_unauthenticated_patron, class: 'Requests::Request' do
    system_id { '9913891213506421' }
    mfhd_id { '22739043950006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :request_serial_with_item_on_hold, class: 'Requests::Request' do
    system_id { '9988406853506421' }
    mfhd_id { '22743233800006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :request_aeon_holding_volume_note, class: 'Requests::Request' do
    system_id { '996160863506421' }
    source { 'pulsearch' }
    mfhd { '22563389780006421' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron, source: source) }
  end

  factory :request_scsb_cu, class: 'Requests::Request' do
    system_id { 'SCSB-5235419' }
    mfhd { nil }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron, source: source) }
  end

  # use_statement: "In Library Use"
  factory :request_scsb_ar, class: 'Requests::Request' do
    system_id { 'SCSB-2650865' }
    mfhd { nil }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron, source: source) }
  end

  factory :request_scsb_mr, class: 'Requests::Request' do
    system_id { 'SCSB-2901229' }
    mfhd { nil }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron, source: source) }
  end

  factory :request_scsb_no_oclc, class: 'Requests::Request' do
    system_id { 'SCSB-5396104' }
    mfhd { nil }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron, source: source) }
  end

  factory :mfhd_with_no_circ_and_circ_item, class: 'Requests::Request' do
    system_id { '992577173506421' }
    mfhd_id { '22591178060006421' }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, patron: patron, mfhd: mfhd_id, source: source) }
  end

  factory :request_scsb_hl, class: 'Requests::Request' do
    system_id { 'SCSB-10966202' }
    mfhd { nil }
    source { 'pulsearch' }
    patron { Requests::Patron.new(user: FactoryBot.build(:unauthenticated_patron)) }
    initialize_with { new(system_id: system_id, mfhd: mfhd, patron: patron, source: source) }
  end
end
