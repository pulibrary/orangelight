# frozen_string_literal: true
require 'factory_bot'

FactoryBot.define do
  factory :request_no_items, class: 'Requests::Form' do
    system_id { '9944928463506421' }
    mfhd { '22490610730006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  #  I think this is a problem record
  factory :request_on_order, class: 'Requests::Form' do
    system_id { '9939075533506421' }
    mfhd { '22675089420006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_thesis, class: 'Requests::Form' do
    system_id { "dsp019c67wp402" }
    mfhd { 'thesis' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_numismatics, class: 'Requests::Form' do
    system_id { "coin-1167" }
    mfhd { 'numismatics' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_paging_available, class: 'Requests::Form' do
    system_id { '9960093633506421' }
    mfhd { '2272418840006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_paging_available_barcode_patron, class: 'Requests::Form' do
    system_id { '9960093633506421' }
    mfhd { '2272418840006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_paging_available_unauthenticated_patron, class: 'Requests::Form' do
    system_id { '9960093633506421' }
    mfhd { '2272418840006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  # missing item
  factory :request_missing_item, class: 'Requests::Form' do
    system_id { '9915486663506421' }
    mfhd { '22495908770006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_on_shelf, class: 'Requests::Form' do
    system_id { '9912140633506421' }
    mfhd { '22722595360006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :aeon_eal_alma_item, class: 'Requests::Form' do
    system_id { '9977213233506421' }
    mfhd { '22707739710006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :aeon_w_barcode, class: 'Requests::Form' do
    system_id { '9995944353506421' }
    mfhd { '22500750240006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :aeon_w_long_title, class: 'Requests::Form' do
    system_id { '9929908463506421' }
    mfhd { '22656754050006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :aeon_no_item_record, class: 'Requests::Form' do
    system_id { '9925358453506421' }
    mfhd { '22615926030006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :aeon_rbsc_alma_enumerated, class: 'Requests::Form' do
    system_id { '996160863506421' }
    mfhd_id { '22563389780006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :aeon_rbsc_enumerated, class: 'Requests::Form' do
    system_id { '9967949663506421' }
    mfhd_id { '22677203260006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :aeon_marquand, class: 'Requests::Form' do
    system_id { '9979153343506421' }
    mfhd_id { '22742463930006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :aeon_mudd, class: 'Requests::Form' do
    system_id { '9960234393506421' }
    mfhd_id { '22524308350006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :aeon_mudd_barcode_patron, class: 'Requests::Form' do
    system_id { '9960234393506421' }
    mfhd_id { '22524308350006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :aeon_mudd_unauthenticated_patron, class: 'Requests::Form' do
    system_id { '9960234393506421' }
    mfhd_id { '22524308350006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :missing_item, class: 'Requests::Form' do
    system_id { '9915486663506421' }
    mfhd_id { '22495908770006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_with_items_charged, class: 'Requests::Form' do
    system_id { '9913891213506421' }
    mfhd_id { '22739043950006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_with_items_charged_barcode_patron, class: 'Requests::Form' do
    system_id { '9913891213506421' }
    mfhd_id { '22739043950006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_with_items_charged_unauthenticated_patron, class: 'Requests::Form' do
    system_id { '9913891213506421' }
    mfhd_id { '22739043950006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_serial_with_item_on_hold, class: 'Requests::Form' do
    system_id { '9988406853506421' }
    mfhd_id { '22743233800006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_aeon_holding_volume_note, class: 'Requests::Form' do
    system_id { '996160863506421' }
    mfhd { '22563389780006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_scsb_cu, class: 'Requests::Form' do
    system_id { 'SCSB-5235419' }
    mfhd { nil }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  # use_statement: "In Library Use"
  factory :request_scsb_ar, class: 'Requests::Form' do
    system_id { 'SCSB-2650865' }
    mfhd { nil }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_scsb_mr, class: 'Requests::Form' do
    system_id { 'SCSB-2901229' }
    mfhd { nil }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :request_scsb_no_oclc, class: 'Requests::Form' do
    system_id { 'SCSB-5396104' }
    mfhd { nil }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :mfhd_with_no_circ_and_circ_item, class: 'Requests::Form' do
    system_id { '992577173506421' }
    mfhd_id { '22591178060006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_col_dev_office, class: 'Requests::Form' do
    system_id { '9911629773506421' }
    mfhd_id { '22608294270006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_holdings_management, class: 'Requests::Form' do
    system_id { '9925798443506421' }
    mfhd_id { '22733278430006421' }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, patron:, mfhd: mfhd_id) }
  end

  factory :request_scsb_hl, class: 'Requests::Form' do
    system_id { 'SCSB-10966202' }
    mfhd { nil }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end

  factory :scsb_manuscript_multi_volume, class: 'Requests::Form' do
    system_id { 'SCSB-7874204' }
    mfhd { nil }
    patron { FactoryBot.build(:patron) }
    initialize_with { new(system_id:, mfhd:, patron:) }
  end
end
