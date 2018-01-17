require 'rails_helper'

describe 'Your Account', type: :feature do
  context 'User has not signed in' do
    it 'Account information displays as not available' do
      visit('/account')
      expect(page).to have_content I18n.t('blacklight.login.netid_button')
    end
  end

  context 'Princeton Community User has signed in' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/generic_voyager_account_response.xml') }
    let(:generic_voyager_account_only_request_items) { fixture('./generic_voyager_account_only_request_items.xml') }
    let(:voyager_account_with_borrow_direct) { fixture('./account_with_borrow_direct_charged_items.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }

    before do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: voyager_account_response, headers: {})

      sign_in user
      visit('/account')
    end

    it 'Displays Basic Patron Information' do
      expect(page).to have_content 'Your Account'
      expect(page).to have_content 'Joe Student'
      expect(page).to have_content '22101008199999'
    end

    it 'Displays item charged out with due dates' do
      expect(page).to have_content 'Charged items'
      expect(page).to have_content 'Due date'
    end

    it 'Displays an unchecked option to renew item request' do
      expect(page).to have_no_checked_field('renew_items[]')
    end

    it 'Displays charged items as renewable' do
      expect(page).to have_css('#item-renew .account--charged_items input')
      expect(page.first(".account--charged_items [data-item-id='17365'] input").value).to eq('17365')
    end

    it 'Displays outstanding fines' do
      expect(page).to have_content I18n.t('blacklight.account.no_fines_fees')
    end

    it 'Display active requests' do
      expect(page).to have_content 'Pickup location'
    end

    it 'Displays items for pickup' do
      expect(page).to have_css('.account--available_items')
    end
  end

  context 'User has charged Borrow Direct Items' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_with_borrow_direct) { fixture('./account_with_borrow_direct_charged_items.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }

    before do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: voyager_account_with_borrow_direct, headers: {})
      sign_in user
      visit('/account')
    end

    it 'displays items with the call number Borrow Direct' do
      expect(page).to have_content('Borrow Direct')
    end
  end

  context 'User with no available pickup items has signed in' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:generic_voyager_account_only_request_items) { fixture('./generic_voyager_account_only_request_items.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }

    before do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: generic_voyager_account_only_request_items, headers: {})

      sign_in user
      visit('/account')
    end

    it 'Displays no items for pickup when none are available' do
      expect(page).to have_content I18n.t('blacklight.account.no_pickup_items')
    end
  end

  context 'Princeton Community User has signed in with a block and active requests' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/voyager_account_with_block.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }

    before do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: voyager_account_response, headers: {})

      sign_in user
      visit('/account')
    end

    it 'displays the patrons block' do
      expect(page).to have_content('Patron blocks')
    end

    it "displays the reason for the patron's block" do
      expect(page).to have_content(I18n.t('blacklight.account.overdue_block'))
    end

    it 'Displays an unchecked option to cancel the request' do
      expect(page).to have_no_checked_field('cancel_requests[]')
    end

    it 'Displays the item and hold recall ID' do
      expect(page).to have_css('#request-cancel .account--requests input')
      expect(page.find('.account--requests #cancel-7114238').value).to eq('item-7114238:holdrecall-587476:type-R')
    end

    it 'Displays the position of the request in the hold queue' do
      expect(page).to have_content('Position: 1')
    end

    it 'Does not display renewal options when patron has a block' do
      expect(page).to have_content(I18n.t('blacklight.account.not_renewable_due_to_patron_block'))
      expect(page).to have_no_checked_field('renew_itemss[]')
    end

    it 'Displays a formatted date when the request expires' do
      expect(page).to have_content('Expires: July 24 2016 at 12:00 AM')
    end

    it 'Displays the selected Pickup Location' do
      expect(page).to have_content('.Firestone Library Circulation Desk')
    end
  end

  context 'Princeton Community User has signed in with an overdue item and fines' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/account_with_block_fines_recall.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }

    before do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: voyager_account_response, headers: {})

      sign_in user
      visit('/account')
    end

    it 'displays item as overdue' do
      expect(page).to have_content('Overdue/Recalled')
    end

    it 'displays properly formatted overdue dates' do
      expect(page).to have_content('January 25 2016 at 11:45 PM')
    end

    it 'displays fines and fines' do
      expect(page).to have_css('.account--fines')
    end

    it 'displays the type of fines' do
      expect(page).to have_content('Overdue/Recalled')
      expect(page).to have_content('Lost Item Replacement')
    end

    it 'displays the amount of fines' do
      expect(page).to have_content('15.00')
      expect(page).to have_content('599.00')
    end

    it 'displays the balance of fines' do
      expect(page).to have_content('15.00')
      expect(page).to have_content('599.00')
      expect(page).to have_content('50.00')
    end

    it 'displays the total amount due' do
      expect(page).to have_css('.account--fines_total')
      expect(page).to have_content('664.00')
    end

    it 'has a data attribute for each charged item' do
      expect(page).to have_xpath("//tr[@data-item-id='7247566']")
      expect(page).to have_xpath("//tr[@data-item-id='7114238']")
      expect(page).to have_xpath("//tr[@data-item-id='5331658']")
    end
  end

  context 'Princeton Community User has signed in to renew and cancel items' do
    let(:user) { FactoryBot.create(:valid_princeton_patron) }
    let(:valid_patron_response) { fixture('/bibdata_patron_response.json') }
    let(:voyager_account_response) { fixture('/voyager_account_with_recall_and_overdue_fines.xml') }
    let(:valid_voyager_patron) { JSON.parse('{"patron_id": "77777"}').with_indifferent_access }
    let(:voyager_authenticate_response) { fixture('/authenticate_patron_response_success.xml') }
    let(:voyager_successful_renew_request) { fixture('/voyager_account_with_recal_and_fines_renew_response.xml') }
    let(:voyager_dbkey_response) { fixture('/voyager_db_info_response.xml') }
    let(:voyager_successful_cancel_request) { fixture('/successful_cancelled_request.xml') }
    let(:voyager_cancel_response_request_item) { fixture('/successful_cancel_response_request_item.xml') }
    let(:voyager_cancel_response_avail_item) { fixture('/successful_cancel_response_avail_item.xml') }
    let(:renew_response_only_success) { fixture('/successful_voyager_renew_response.xml') }

    before do
      stub_request(:get, "#{ENV['bibdata_base']}/patron/#{user.uid}")
        .to_return(status: 200, body: valid_patron_response, headers: {})

      valid_patron_record_uri = "#{ENV['voyager_api_base']}/vxws/MyAccountService?patronId=#{valid_voyager_patron[:patron_id]}&patronHomeUbId=1@DB"
      stub_request(:get, valid_patron_record_uri)
        .to_return(status: 200, body: voyager_account_response, headers: {})

      stub_request(:get, "#{ENV['voyager_api_base']}/vxws/dbInfo?option=dbinfo")
        .to_return(status: 200, body: voyager_dbkey_response, headers: {})

      stub_request(:post, "#{ENV['voyager_api_base']}/vxws/AuthenticatePatronService")
        .with(headers: { 'Content-type' => 'application/xml' })
        .to_return(status: 200, body: voyager_authenticate_response, headers: {})

      stub_request(:post, "#{ENV['voyager_api_base']}/vxws/RenewService")
        .with(headers: { 'Content-type' => 'application/xml' })
        .to_return(status: 200, body: voyager_successful_renew_request, headers: {})

      stub_request(:post, "#{ENV['voyager_api_base']}/vxws/CancelService")
        .with(headers: { 'Content-type' => 'application/xml' })
        .to_return(status: 200, body: voyager_successful_cancel_request, headers: {})

      sign_in user
      visit('/account')
    end

    describe 'User can renew', js: true do
      it "returns a failure message when the request can't be processed" do
        stub_request(:post, "#{ENV['voyager_api_base']}/vxws/RenewService")
          .with(headers: { 'Content-type' => 'application/xml' })
          .to_return(status: 500, body: 'Bad thing happened', headers: {})

        check('select-all-renew')
        click_button('Renew selected items')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.renew_fail'))
      end

      it 'but no items are selected for renewal' do
        click_button('Renew selected items')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.renew_no_items'))
      end

      it 'selected items' do
        stub_request(:post, "#{ENV['voyager_api_base']}/vxws/RenewService")
          .with(headers: { 'Content-type' => 'application/xml' })
          .to_return(status: 200, body: renew_response_only_success, headers: {})
        check('charged-7193128')
        expect(find('#charged-7193128')).to be_checked
        click_button('Renew selected items')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.renew_success'))
      end

      # Not sure how to test this one
      it 'by selecting all charged items' do
        check('select-all-renew')
        within('#item-renew') do
          all('input[type=checkbox]').each do |checkbox|
            expect(checkbox).to be_checked
          end
        end
      end

      it 'displays a confirmation message for each successfully renewed item' do
        check('select-all-renew')
        expect(page).to have_xpath("//tr[@data-item-id='3688389']")
        click_button('Renew selected items')
        wait_for_ajax
        expect(page).to have_selector(".success[data-item-id='3688389']")
        expect(find(:xpath, "//tr[@data-item-id='3688389']/td/span[@class='item--messages']/b").text).to eq('Renewed')
      end

      it 'displays a block message for each item that cannot be renewed' do
        check('select-all-renew')
        expect(page).to have_xpath("//tr[@data-item-id='7193128']")
        click_button('Renew selected items')
        wait_for_ajax
        expect(page).to have_selector(".danger[data-item-id='7193128']")
        expect(find(:xpath, "//tr[@data-item-id='7193128']/td/span[@class='item--messages']/span[@class='message']").text).to eq('Item not authorized for renewal.')
        expect(find(:xpath, "//tr[@data-item-id='7193128']/td/span[@class='item--messages']/b").text).to eq('Not Renewed')
      end

      it 'displays a flash message indicating all items cannot be renewed' do
        check('select-all-renew')
        click_button('Renew selected items')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.renew_partial_fail'))
      end
    end

    describe 'User can cancel', js: true do
      it "returns a failure message when the request can't be processed" do
        stub_request(:post, "#{ENV['voyager_api_base']}/vxws/CancelService")
          .with(headers: { 'User-Agent' => 'Faraday v0.11.0', 'Content-type' => 'application/xml' })
          .to_return(status: 500, body: 'bad thing happened', headers: {})
        check('cancel-7114238')
        click_button('Cancel requests')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.cancel_fail'))
      end

      it 'but no requests are selected for cancellation' do
        click_button('Cancel requests')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.cancel_no_items'))
      end

      it 'selected requests' do
        stub_request(:post,  "#{ENV['voyager_api_base']}/vxws/CancelService")
          .with(headers: { 'Content-type' => 'application/xml' })
          .to_return(status: 200, body: voyager_cancel_response_avail_item, headers: {})
        check('cancel-7114238')
        expect(find('#cancel-7114238')).to be_checked
        click_button('Cancel requests')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.cancel_success'))
        expect(page).to have_no_selector('#cancel-7114238')
        expect(page).to have_selector('#cancel-42289')
      end

      it 'selected available pickup items' do
        stub_request(:post,  "#{ENV['voyager_api_base']}/vxws/CancelService")
          .with(headers: { 'Content-type' => 'application/xml' })
          .to_return(status: 200, body: voyager_cancel_response_request_item, headers: {})
        check('cancel-42289')
        expect(find('#cancel-42289')).to be_checked
        click_button('Cancel requests')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.cancel_success'))
        expect(page).to have_selector('#cancel-7114238')
        expect(page).to have_no_selector('#cancel-42289')
      end

      it 'selected requests and pickup items' do
        check('cancel-7114238')
        expect(find('#cancel-7114238')).to be_checked
        check('cancel-42289')
        expect(find('#cancel-42289')).to be_checked
        click_button('Cancel requests')
        wait_for_ajax
        expect(page).to have_content(I18n.t('blacklight.account.cancel_success'))
        expect(page).to have_no_selector('#cancel-7114238')
        expect(page).to have_no_selector('#cancel-42289')
      end
    end
  end
end
