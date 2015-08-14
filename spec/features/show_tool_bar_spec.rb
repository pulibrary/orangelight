require 'rails_helper'

describe "Tools links"  do

    before(:each) do
        visit  "/catalog?search_field=all_fields&q="
        within ".documents-list" do
          first(:link).click
        end
    end

    ['SMS', 'Email', 'Librarian View', 'Cite', 'Classic Catalog'].each do |link_text|
        it "#{link_text} appears for record view" do
            find_link(link_text)
        end
    end

    ['RefWorks', 'EndNote'].each do |link_text|
        it "provides #{link_text} export options in dropdown" do
            within "#previousNextDocument li.dropdown" do
                find_link(link_text)
            end
        end
    end

    ['Add to Folder', 'Send to'].each do |button_text|
        it "has #{button_text} button" do
            find_button(button_text)
        end
    end
end