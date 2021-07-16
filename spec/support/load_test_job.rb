# frozen_string_literal: true

require Rails.root.join('spec', 'support', 'capybara_selenium')
require 'webdrivers/chromedriver'
require 'logger'
require Rails.root.join('spec', 'support', 'url_file_generator')

class LoadTestJob
  def self.noun_file
    Rails.root.join('spec', 'fixtures', 'load_testing_urls', "nouns.txt")
  end

  def self.adj_file
    Rails.root.join('spec', 'fixtures', 'load_testing_urls', "adjectives.txt")
  end

  def self.base_url
    "https://catalog.princeton.edu"
  end

  def self.url_file_generator
    @url_file_generator ||= UrlFileGenerator.new(noun_file: noun_file, adj_file: adj_file, base_url: base_url, lines: @requests)
  end

  def self.generated_urls
    @generated_urls ||= url_file_generator.generate
  end

  def self.session
    @session ||= Capybara::Session.new(:selenium_headless)
  end

  def self.default_max_wait_time
    @default_max_wait_time ||= Capybara.default_max_wait_time
  end

  def self.persist_max_wait_time!
    @default_max_wait_time = Capybara.default_max_wait_time
  end

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def self.headings
    [
      'URL',
      'Time',
      'Available Holdings',
      'Online Holdings',
      'Missing Holdings',
      'Online Access Holdings',
      'On-site Access Holdings',
      'Default Thumbnails',
      'Item Thumbnails'
    ]
  end

  def self.perform_now(requests:)
    @requests = requests

    persist_max_wait_time!
    Capybara.default_max_wait_time = 2

    results = {
      headings: headings
    }
    rows = []

    generated_urls.each do |url|
      logger.info("Requesting #{url}...")
      session.visit(url)
      time = DateTime.now.iso8601

      row = {
        url: url,
        time: time.iso8601
      }

      search_result_articles = session.find_all('#documents .document')
      row[:search_results] = search_result_articles.length

      article = session

      available_holdings = 0
      online_holdings = 0
      missing_holdings = 0
      online_access_holdings = 0
      on_site_access_holdings = 0

      availability_elements = article.find_all('.availability-icon')

      available_elements = availability_elements.select { |e| e.text == 'Available' }
      online_elements = availability_elements.select { |e| e.text == 'Online' }
      missing_elements = availability_elements.select { |e| e.text == 'Missing' }
      online_access_elements = availability_elements.select { |e| e.text == 'Online access' }
      on_site_access_elements = availability_elements.select { |e| e.text == 'On-site access' }

      available_holdings += available_elements.length
      online_holdings += online_elements.length
      missing_holdings += missing_elements.length
      online_access_holdings += online_access_elements.length
      on_site_access_holdings += on_site_access_elements.length

      thumbnail_elements = if article.has_selector?('.document-thumbnail')
                             article.find_all('.document-thumbnail')
                           else
                             []
                           end

      default_thumbnail_elements = thumbnail_elements.select { |e| e.has_selector?('.default') }
      default_thumbnails = default_thumbnail_elements.length

      item_thumbnail_elements = thumbnail_elements.select { |e| e.has_selector?('img') }
      item_thumbnails = item_thumbnail_elements.length

      rows << row.merge(
        available_holdings: available_holdings,
        online_holdings: online_holdings,
        missing_holdings: missing_holdings,
        online_access_holdings: online_access_holdings,
        on_site_access_holdings: on_site_access_holdings,
        default_thumbnails: default_thumbnails,
        item_thumbnails: item_thumbnails
      )
    end

    results[:rows] = rows.map(&:values)

    Capybara.default_max_wait_time = default_max_wait_time

    OpenStruct.new(results)
  end
end
