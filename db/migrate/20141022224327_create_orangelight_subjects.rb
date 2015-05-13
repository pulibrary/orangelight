class CreateOrangelightSubjects < ActiveRecord::Migration
  def change
    create_table :orangelight_subjects do |t|
      t.text :label
      t.integer :count
      t.text :sort, index: true
      t.string :dir
    end
  end
end
