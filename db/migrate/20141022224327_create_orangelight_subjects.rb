class CreateOrangelightSubjects < ActiveRecord::Migration
  def change
    create_table :orangelight_subjects do |t|
      t.string :label
      t.integer :count
      t.string :sort
      t.string :dir
    end
  end
end
