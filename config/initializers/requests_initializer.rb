# frozen_string_literal: true

require 'faraday'

module Requests
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  private

  def config_yaml
    raise "You are missing a configuration file: #{requests_config_file}. Have you run \"rails generate requests:install\"?" unless File.exist?(requests_config_file)

    begin
      requests_erb = ERB.new(IO.read(requests_config_file)).result(binding)
    rescue StandardError, SyntaxError => e
      raise("#{requests_config_file} was found, but could not be parsed with ERB. \n#{e.inspect}")
    end

    begin
      YAML.safe_load(requests_erb, aliases: true)[Rails.env]
    rescue => e
      raise("#{requests_config_file} was found, but could not be parsed.\n#{e.inspect}")
    end
  end

  def requests_config_file
    Rails.root.join('config', 'requests.yml')
  end
  module_function :config, :config_yaml, :requests_config_file
end
