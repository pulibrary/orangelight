require 'rails_helper'

describe 'Tools links' do
  context 'With MARC-based records' do
    before(:each) do
      visit  '/catalog?search_field=all_fields&q='
      within '.documents-list' do
        first(:link).click
      end
    end

    ['SMS', 'Email', 'Librarian View', 'Cite', I18n.t('blacklight.voyager')].each do |link_text|
      it "#{link_text} appears for record view" do
        within '#main-container' do
          find_link(link_text)
        end
      end
    end

    %w(RefWorks EndNote).each do |link_text|
      it "provides #{link_text} export options in dropdown" do
        within '#previousNextDocument li.dropdown' do
          find_link(link_text)
        end
      end
    end

    # ['Add to Folder', 'Send to'].each do |button_text|
    ['Send to'].each do |button_text|
      it "has #{button_text} button" do
        find_button(button_text)
      end
    end
  end

  context 'With non-MARC-based records' do
    before(:each) do
      visit  '/catalog?search_field=all_fields&q=dsp01ft848s955'
      within '.documents-list' do
        first(:link).click
      end
    end

    it 'does not have a cite link' do
      within '#main-container' do
        expect(page).not_to have_link('Cite')
      end
    end

    %w(RefWorks EndNote).each do |link_text|
      it "provides #{link_text} export options in dropdown" do
        within '#previousNextDocument li.dropdown' do
          expect(page).not_to have_link(link_text)
        end
      end
    end
  end
end
