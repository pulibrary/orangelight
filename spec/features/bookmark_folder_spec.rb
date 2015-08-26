# require 'rails_helper'

# describe "Blacklight bookmark folders interaction" do

#     it "adds record to default folder and confirms with alert message" do
#         visit  "/catalog?search_field=all_fields&q="
#         within ".documents-list" do
#           first(:link).click
#         end
#         select('Default folder', :from => 'folder_id')
#         click_button("Add to Folder")
#         expect(page.has_content?("Added document to Default folder")).to eq true
#         visit "/blacklight/folders/"
#         within ".table" do
#             first(:link).click
#         end
#         expect(page.all('.document').length).to eq 1
#         within "#documents" do
#             first(:link).click
#         end
#         expect(page.has_content?("Contained in")).to eq true
#     end

# end
