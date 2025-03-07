class AddVocabularyToBrowse < ActiveRecord::Migration[6.0]
  def change
    add_column :alma_orangelight_subjects, :vocabulary, :string
  end
end
