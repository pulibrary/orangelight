# frozen_string_literal: true

require 'rails_helper'

describe 'Tools links' do
  before { stub_holding_locations }

  context 'With MARC-based records' do
    before do
      visit  '/catalog?search_field=all_fields&q='
      within '.documents-list' do
        first(:link).click
      end
    end

    [I18n.t('blacklight.header_links.course_reserves'), I18n.t('blacklight.header_links.bookmarks')].each do |link_text|
      it "#{link_text} appears for navbar" do
        find('.navbar-item * a', text: link_text)
      end
    end

    [I18n.t('blacklight.header_links.login'), I18n.t('blacklight.header_links.search_history')].each do |link_text|
      it "#{link_text} appears for your account dropdown" do
        within '.menu--level-1' do
          find_link(link_text)
        end
      end
    end

    ['SMS', 'Email', I18n.t('blacklight.tools.librarian_view'), 'Cite'].each do |link_text|
      it "#{link_text} appears for record view" do
        within '#main-container' do
          find_link(link_text)
        end
      end
    end

    %w[RefWorks EndNote].each do |link_text|
      it "provides #{link_text} export options in dropdown" do
        within '.search-widgets li.dropdown' do
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
    before do
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

    %w[RefWorks EndNote].each do |link_text|
      it "provides #{link_text} export options in dropdown" do
        within '.search-widgets li.dropdown' do
          expect(page).not_to have_link(link_text)
        end
      end
    end
  end
end
