class CreateOrangelightCallNumbers < ActiveRecord::Migration[4.2]
  def change
    create_table :orangelight_call_numbers do |t|
      t.string :label
      t.string :dir
      t.string :scheme
      t.string :sort, index: true
      t.text :title
      t.text :author
      t.text :date
      t.string :bibid

    end
  end
end
