class Orangelight::NameTitle < ActiveRecord::Base
  def self.table_name_prefix
    'orangelight_'
  end
end
