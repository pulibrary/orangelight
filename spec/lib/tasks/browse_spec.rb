# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'browse rake tasks' do
  self.use_transactional_tests = false
  before do
    Orangelight::Application.load_tasks
  end

  describe 'browse:load_names' do
    around do |example|
      # Clear the browse lists
      Orangelight::Name.destroy_all

      # Run the tests
      example.run

      # Reload the browse lists again
      Rake::Task['browse:names'].invoke
      run_described_task
    end
    it 'adds entries to the database in the correct order' do
      FileUtils.cp file_fixture('name_browse_unsorted.csv'), '/tmp/alma_orangelight_names.csv'

      run_described_task

      expect(Orangelight::Name.all.pluck('label')).to eq([
                                                           "Ibn ʻAbd al-Barr, Yūsuf ibn ʻAbd Allāh, 978 or 979-1071",
                                                           "Ibn Abd al-Malik, Azizi",
                                                           "Ibn al-ʻArabī",
                                                           "Ibn al-ʻArabī, al-Ṣiddīq",
                                                           "Ibn al-Arabi, Muhammad ibn Abd Allah",
                                                           "Ibn al-Armanāzī, Ghayth ibn ʻAlī, 1051 or 1052-1115 or 1116",
                                                           "Mander, Samuel S.",
                                                           "Marnell, John",
                                                           "بهاء الدين، احمد."
                                                         ])
    end
  end

  def run_described_task
    Rake::Task['browse:load_names'].invoke
    Rake::Task['browse:load_names'].clear
    Rake::Task['browse:load_names'].reenable
  end
end
