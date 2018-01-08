# frozen_string_literal: false

# Service for generating robots.txt from the routes
class RobotsGeneratorService
  # Generate a robots.txt with the default values
  def self.default
    file_path = Rails.root.join('public', 'robots.txt')
    robots = RobotsGeneratorService.new(
      path: file_path,
      disallowed_paths: Rails.configuration.robots.disallowed_paths
    )
    robots.insert_group(user_agent: '*')
    robots.insert_crawl_delay(10)
    robots.insert_sitemap(Rails.configuration.robots.sitemap_url)
    robots.generate
    robots.write
  end

  # Constructor
  # @param path [String] path for the robots.txt
  # @param path [Array<String>] an array of disallowed paths
  def initialize(path:, disallowed_paths: [])
    @path = path
    @disallowed_paths = disallowed_paths

    @groups = [[]]
    @content = ''
  end

  # Insert a Disallow directive
  # @param pattern [String] the path or pattern to prevent robots from crawling
  def disallow(pattern)
    @groups.last << "Disallow: #{pattern}\n"
  end

  # Generate the robots.txt directives
  def generate
    generate_disallow_directives
    @groups.each do |rules|
      rules.each do |rule|
        @content << rule
      end
    end
  end

  # Write the directives to a file
  def write
    File.open(@path, 'w+b') do |f|
      f << @content
    end
  end

  # Insert a group of directives for a given user-agent
  # @param user_agent [String] the user agent of the crawler
  def insert_group(user_agent:)
    @groups << []
    @content << "User-agent: #{user_agent}\n"
  end

  # Insert the delay for the crawler
  # @param delay [Integer] the delay
  def insert_crawl_delay(delay)
    @content << "Crawl-delay: #{delay}\n"
  end

  # Insert the link to the sitemap
  # @param sitemap_url [String] the URL for the GZipped sitemap
  def insert_sitemap(sitemap_url)
    @content << "Sitemap: #{sitemap_url}\n"
  end

  private

    # Generate the directives for all paths explicitly disallowed
    def generate_disallow_directives
      @disallowed_paths.each do |path|
        disallow(path)
      end
    end
end
