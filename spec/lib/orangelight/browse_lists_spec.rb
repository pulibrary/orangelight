# frozen_string_literal: true
require 'rails_helper'
require 'orangelight/browse_lists'
require 'orangelight/browse_lists/call_number_csv'

RSpec.describe BrowseLists, browse: true do
  let(:csv_file_path) { "/tmp/alma_orangelight_names.csv" }
  let(:truncate_command) { /TRUNCATE TABLE/ }

  before do
    allow(described_class).to receive(:system).and_call_original
    FileUtils.rm_f(csv_file_path)
  end

  context 'with an existing CSV file with no data' do
    before do
      FileUtils.touch(csv_file_path)
    end

    it 'does not truncate a table if there is no data in the CSV to re-populate it from' do
      sql_command, facet_request, conn = described_class.connection
      expect do
        described_class.load_facet(sql_command, facet_request, conn,
                                   'author_s', "#{described_class.table_prefix}_names")
      end.to raise_error(StandardError, 'CSV file too short - 0 lines long. Expected at least 9 lines.')
      expect(described_class).not_to have_received(:system).with(truncate_command)
    end
  end

  context 'with a missing CSV file' do
    it 'does not truncate a table if there is no CSV to re-populate it from' do
      sql_command, facet_request, conn = described_class.connection
      expect do
        described_class.load_facet(sql_command, facet_request, conn,
                                   'author_s', "#{described_class.table_prefix}_names")
      end.to raise_error(Errno::ENOENT)
      expect(described_class).not_to have_received(:system).with(truncate_command)
    end
  end
end
