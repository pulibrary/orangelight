class AddVocabularyToBrowse < ActiveRecord::Migration[5.1]
  def change
    add_column :orangelight_subjects, :vocabulary, :string
  end
end
