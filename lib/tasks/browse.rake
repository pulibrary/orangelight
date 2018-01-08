# frozen_string_literal: true

require './lib/orangelight/browse_lists'

namespace :browse do
  desc 'Pull data for names browse'
  task :names do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'author_s', 'orangelight_names')
  end

  desc 'Pull data for names browse'
  task :name_titles do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'name_title_browse_s', 'orangelight_name_titles')
  end

  desc 'Pull data for subjects browse'
  task :subjects do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'subject_facet', 'orangelight_subjects')
  end

  desc 'Pull data for call numbers browse'
  task :call_numbers do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_cn(sql_command, facet_request, conn,
                          'call_number_browse_s', 'orangelight_call_numbers')
  end

  desc 'Pull data for names browse'
  task :load_names do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'author_s', 'orangelight_names')
  end

  desc 'Pull data for names browse'
  task :load_name_titles do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'name_title_browse_s', 'orangelight_name_titles')
  end

  desc 'Pull data for subjects browse'
  task :load_subjects do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'subject_facet', 'orangelight_subjects')
  end

  desc 'Sort and load call numbers'
  task :load_call_numbers do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_cn(sql_command, facet_request, conn, 'call_number_browse_s',
                        'orangelight_call_numbers')
  end

  desc 'Pull data for all browse tables'
  task :all do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'author_s', 'orangelight_names')
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'name_title_browse_s', 'orangelight_name_titles')
    BrowseLists.browse_facet(sql_command, facet_request, conn,
                             'subject_facet', 'orangelight_subjects')
    BrowseLists.browse_cn(sql_command, facet_request, conn, 'call_number_browse_s',
                          'orangelight_call_numbers')
  end

  desc 'Sort and load data for all browse tables'
  task :load_all do
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'author_s', 'orangelight_names')
    sql_command, facet_request, conn = BrowseLists.connection
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'name_title_browse_s', 'orangelight_name_titles')
    BrowseLists.load_facet(sql_command, facet_request, conn,
                           'subject_facet', 'orangelight_subjects')
    BrowseLists.load_cn(sql_command, facet_request, conn, 'call_number_browse_s',
                        'orangelight_call_numbers')
  end
end
