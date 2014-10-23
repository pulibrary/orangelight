# require 'rails_helper'

# RSpec.describe "browse/names/index", :type => :view do
#   before(:each) do
#     assign(:orangelight_browsables, [
#       Orangelight::Name.create!(
#         :label => "Label",
#         :count => 1,
#         :sort => "Sort",
#         :dir => "Dir"
#       ),
#       Orangelight::Name.create!(
#         :label => "Label",
#         :count => 1,
#         :sort => "Sort",
#         :dir => "Dir"
#       )
#     ])
#   end

#   it "renders a list of browse/names" do
#     render_template
#     assert_select "tr>td", :text => "Label".to_s, :count => 2
#     assert_select "tr>td", :text => 1.to_s, :count => 2
#     assert_select "tr>td", :text => "Sort".to_s, :count => 2
#     assert_select "tr>td", :text => "Dir".to_s, :count => 2
#   end
# end
