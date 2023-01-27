# frozen_string_literal: true

require './lib/orangelight/browse_lists'
require './lib/orangelight/browse_lists/call_number_csv'

namespace :browse do
  desc 'Pull data for names browse'
  task :names do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'author_s', "#{BrowseLists.table_prefix}_names")
  end

  desc 'Pull data for names browse'
  task :name_titles do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'name_title_browse_s', "#{BrowseLists.table_prefix}_name_titles")
  end

  desc 'Pull data for subjects browse'
  task :subjects do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_subject(sql_command, facet_request, conn)
  end

  desc 'Pull data for call numbers browse'
  task call_numbers: :environment do
    _sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists::CallNumberCSV.new(facet_request, conn).write
  end

  desc 'Sort and load data for names browse'
  task :load_names do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'author_s', "#{BrowseLists.table_prefix}_names")
  end

  desc 'Sort and load data for name titles browse'
  task :load_name_titles do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'name_title_browse_s', "#{BrowseLists.table_prefix}_name_titles")
  end

  desc 'Sort and load data for subjects browse'
  task :load_subjects do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_subject(sql_command, facet_request, conn,
                           'subject_facet', 'alma_orangelight_subjects')
  end

  desc 'Sort and load call numbers'
  task :load_call_numbers do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_cn(sql_command, facet_request, conn, 'call_number_browse_s',
                        "#{BrowseLists.table_prefix}_call_numbers")
  end

  desc 'loads sorted BACKUP_FILE, default /tmp/orangelight_names.sorted.backup'
  task :load_names_backup do
    sorted_backup_file = ENV['BACKUP_FILE'] || '/tmp/orangelight_names.sorted.backup'
    sql_command, _facet_request, _conn = BrowseLists.connection
    BrowseLists.load_facet_file(sql_command, sorted_backup_file, "#{BrowseLists.table_prefix}_names")
  end

  desc 'loads sorted BACKUP_FILE, default /tmp/orangelight_name_titles.sorted.backup'
  task :load_name_titles_backup do
    sorted_backup_file = ENV['BACKUP_FILE'] || '/tmp/orangelight_name_titles.sorted.backup'
    sql_command, _facet_request, _conn = BrowseLists.connection
    BrowseLists.load_facet_file(sql_command, sorted_backup_file, "#{BrowseLists.table_prefix}_name_titles")
  end

  desc 'loads sorted BACKUP_FILE, default /tmp/orangelight_subjects.sorted.backup'
  task :load_subjects_backup do
    sorted_backup_file = ENV['BACKUP_FILE'] || '/tmp/orangelight_subjects.sorted.backup'
    sql_command, _facet_request, _conn = BrowseLists.connection
    BrowseLists.load_facet_file(sql_command, sorted_backup_file, "#{BrowseLists.table_prefix}_subjects")
  end

  desc 'loads sorted BACKUP_FILE, default /tmp/call_number_browse_s.sorted.backup'
  task :load_call_numbers_backup do
    sorted_backup_file = ENV['BACKUP_FILE'] || '/tmp/call_number_browse_s.sorted.backup'
    sql_command, _facet_request, _conn = BrowseLists.connection
    BrowseLists.load_cn_file(sql_command, sorted_backup_file, "#{BrowseLists.table_prefix}_call_numbers")
  end

  desc 'Pull data for all browse tables'
  task :all do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'author_s', "#{BrowseLists.table_prefix}_names")
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'name_title_browse_s', "#{BrowseLists.table_prefix}_name_titles")
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'subject_facet', "#{BrowseLists.table_prefix}_subjects")
    BrowseLists::CallNumberCSV.new(facet_request, conn).write
  end

  desc 'Sort and load data for all browse tables'
  task :load_all do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'author_s', "#{BrowseLists.table_prefix}_names")
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'name_title_browse_s', "#{BrowseLists.table_prefix}_name_titles")
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'subject_facet', "#{BrowseLists.table_prefix}_subjects")
    BrowseLists.load_cn(sql_command, facet_request, conn, 'call_number_browse_s',
                        "#{BrowseLists.table_prefix}_call_numbers")
  end
end
