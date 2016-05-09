class Orangelight::Subject < ActiveRecord::Base
  def self.table_name_prefix
    'orangelight_'
  end
end
