class CreateHathiPulMatches < ActiveRecord::Migration[5.1]
  def change
    create_table :hathi_pul_matches do |t|
      t.string :oclc
      t.string :pul_id
      t.string :item_type
      t.string :access
      t.string :rights

      t.timestamps
    end
  end
end
