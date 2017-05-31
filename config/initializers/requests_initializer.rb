require 'faraday'

module Requests

  def config
    @config ||= config_yaml.with_indifferent_access
  end

  private

    def config_yaml

      unless File.exist?(requests_config_file)
        raise "You are missing a configuration file: #{requests_config_file}. Have you run \"rails generate requests:install\"?"
      end

      begin
        requests_erb = ERB.new(IO.read(requests_config_file)).result(binding)
      rescue StandardError, SyntaxError => e
        raise("#{requests_config_file} was found, but could not be parsed with ERB. \n#{e.inspect}")
      end

      begin
        YAML.load(requests_erb)[Rails.env]
      rescue => e
        raise("#{requests_config_file} was found, but could not be parsed.\n#{e.inspect}")
      end
    end

    def requests_config_file
      "#{Rails.root}/config/requests.yml"
    end

    module_function :config, :config_yaml, :requests_config_file
end


# initialize location data
delivery_locations = Faraday.get("#{Requests.config[:bibdata_base]}/locations/delivery_locations.json")

unless delivery_locations.status != 200
  DELIVERY_LOCATIONS = {}.with_indifferent_access
  JSON.parse(delivery_locations.body).each do |location|
    DELIVERY_LOCATIONS[location['gfa_pickup']] = location.with_indifferent_access
  end
end
