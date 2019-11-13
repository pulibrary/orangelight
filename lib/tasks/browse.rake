# frozen_string_literal: true

require './lib/orangelight/browse_lists'

namespace :browse do
  desc 'Run the development Solr'
  task solr: [:environment] do
    run_browse_lists_solr(Rails.env, port: '8983', persist: true) do
      # Populate the browse list collection
      sleep
    end
  end

  desc 'Generate and load the data for the names browse list'
  task names: [:environment] do
    BrowseLists.browse_facet('author_s', 'names')
  end

  desc 'Generate and load the data for the titles browse list'
  task name_titles: [:environment] do
    BrowseLists.browse_facet('name_title_browse_s', 'name_titles')
  end

  desc 'Generate and load the data for the subjects browse list'
  task subjects: [:environment] do
    BrowseLists.browse_facet('subject_facet', 'subjects')
  end

  desc 'Generate and load the data for the call numbers browse list'
  task call_numbers: [:environment] do
    BrowseLists.browse_call_numbers('call_number_browse_s', 'call_numbers')
  end

  desc 'Generate and load the data for all browse lists'
  task all: [:environment] do
    BrowseLists.browse_facet('author_s', 'names')
    BrowseLists.browse_facet('name_title_browse_s', 'name_titles')
    BrowseLists.browse_facet('subject_facet', 'subjects')
    BrowseLists.browse_call_numbers('call_number_browse_s', 'call_numbers')
  end

  # Generate a Solr installation with cores for both Blacklight and the Browse Lists
  # @param environment [String] the Rails environment
  # @param custom_solr_params [Hash] the SolrWrapper options
  def run_browse_lists_solr(environment, custom_solr_params)
    Rake::Task['pulsearch:solr:update'].invoke

    current_path = File.dirname(__FILE__)
    browse_lists_solr_path = File.join(current_path, '..', '..', 'solr')
    browse_lists_conf_path = File.join(browse_lists_solr_path, 'conf')
    browse_lists_collection_name = "browse-lists-core-#{environment}"

    default_solr_params = {
      managed: true,
      verbose: true,
      persist: false,
      download_dir: "tmp",
      instance_dir: "tmp/#{browse_lists_collection_name}"
    }
    solr_params = default_solr_params.merge(custom_solr_params)

    SolrWrapper.wrap(solr_params) do |solr|
      ENV['SOLR_TEST_PORT'] = solr.port

      # Create the Solr collection
      solr_client = SolrWrapper::Client.new(solr.url)
      solr.delete(browse_lists_collection_name) if solr_client.exists?(browse_lists_collection_name)
      solr.create(name: browse_lists_collection_name, dir: browse_lists_conf_path)

      puts "\n#{environment.titlecase} solr server running: #{solr.url}#/#{browse_lists_collection_name}"

      Rake::Task['pulsearch:solr:update'].invoke(browse_lists_solr_path)

      blacklight_collection_name = "orangelight-core-#{environment}"
      # This needs to be changed once a separate config. set is used
      blacklight_collection_conf_path = browse_lists_conf_path
      blacklight_collection_params = {
        name: blacklight_collection_name,
        dir: blacklight_collection_conf_path,
        instance_dir: "tmp/#{blacklight_collection_name}"
      }

      solr.with_collection(blacklight_collection_params) do
        # Seed the collection for the catalog
        Rake::Task['pulsearch:solr:index'].invoke
        # Seed the collection for the browse lists
        Rake::Task['browse:all'].invoke

        puts "\n#{environment.titlecase} solr server running: http://localhost:#{solr.port}/solr/#/orangelight-core-#{environment}"
        puts "\n^C to stop"
        puts ' '
        begin
          yield
        rescue Interrupt
          puts 'Shutting down...'
        end
      end
    end
  end
end
