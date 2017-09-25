require 'rails_helper'

describe 'SCSB Shared Collection Records' do
  context 'Search Results Page' do
    it 'displays view full record for multi-item records' do
      visit '/catalog?search_field=all_fields&q=SCSB-2443272'
      expect(page).to have_content 'View Record for Full Availability'
    end
    it 'displays on-site access for supervised use items' do
      visit '/catalog?search_field=all_fields&q=SCSB-6593031'
      expect(page).to have_content 'On-site access'
      expect(page).to have_selector 'span.icon-request-reading-room'
    end
    it 'includes a data attribute to trigger availability check against scsb' do
      visit '/catalog?search_field=all_fields&q=SCSB-2143785'
      expect(page).to have_selector("*[data-scsb-availability='true']")
    end
    it 'includes a data attribute with a scsb barcode' do
      visit '/catalog?search_field=all_fields&q=SCSB-2143785'
      expect(page).to have_selector("*[data-scsb-barcode='AR00234770']")
    end
  end
  context 'Record with no use restrictions' do
    before(:each) do
      visit '/catalog/SCSB-2443272'
    end
    it 'displays a request button' do
      expect(page).to have_content 'Request'
    end
    it 'displays RCP Collection Codes for the partner library' do
      expect(page).to have_content 'RCP'
      expect(page).to have_content 'C - S'
    end
  end

  context 'Record with Supervised Use Restrictions' do
    before(:each) do
      visit '/catalog/SCSB-6593031'
    end
    it 'displays use restrictions' do
      expect(page).to have_content 'Use Restrictions:'
      expect(page).to have_content 'Supervised Use'
    end
    it 'displays a Reading Room Request' do
      expect(page).to have_content 'Reading Room Request'
    end
    it 'displays RCP Collection Codes for the partner library' do
      expect(page).to have_content 'RCP'
      expect(page).to have_content 'N - S'
    end
  end

  context 'Record with In Library Use Restriction' do
    before(:each) do
      visit '/catalog/SCSB-2143785'
    end
    it 'displays the restriction' do
      expect(page).to have_content 'Use Restrictions:'
      expect(page).to have_content 'In Library Use'
    end
    it 'displays a request button' do
      expect(page).to have_content 'Request'
    end
  end
  context 'Record with In Library Use and Supervised Use Restrictions' do
    before(:each) do
      visit '/catalog/SCSB-7846265'
    end
    it 'displays a Request Button' do
      expect(page).to have_content 'Request'
    end
  end
end
