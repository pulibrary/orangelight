# frozen_string_literal: true

module Orangelight
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  def self.browse_lists_config_file
    "#{::Rails.root}/config/browse_lists.yml"
  end

  def self.browse_lists_yml
    require 'erb'
    require 'yaml'

    return @browse_lists_yml if @browse_lists_yml
    raise "You are missing a configuration file: #{browse_lists_config_file}. Have you run \"rails generate blacklight:install\"?" unless File.exist?(browse_lists_config_file)

    begin
      blacklight_erb = ERB.new(IO.read(browse_lists_config_file)).result(binding)
    rescue StandardError, SyntaxError => e
      raise("#{browse_lists_config_file} was found, but could not be parsed with ERB. \n#{e.inspect}")
    end

    begin
      @browse_lists_yml = YAML.safe_load(blacklight_erb)
    rescue => e
      raise("#{browse_lists_config_file} was found, but could not be parsed.\n#{e.inspect}")
    end

    raise("#{browse_lists_config_file} was found, but was blank or malformed.\n") if @browse_lists_yml.nil? || !@browse_lists_yml.is_a?(Hash)

    @browse_lists_yml
  end

  def self.connection_config
    raise "The #{::Rails.env} environment settings were not found in the browse_lists.yml config" unless browse_lists_yml[::Rails.env]

    browse_lists_yml[::Rails.env].symbolize_keys
  end

  def self.default_configuration
    Blacklight::Configuration.new(connection_config: connection_config)
  end

  def self.repository_class
    Blacklight.repository_class
  end

  def self.browse_lists_index
    repository_class.new(default_configuration)
  end

  private

    def config_yaml
      path = Rails.root.join('config', 'orangelight.yml')
      YAML.safe_load(ERB.new(File.read(path)).result, [], [], true)[Rails.env]
    end

    module_function :config, :config_yaml
end
