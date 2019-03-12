# frozen_string_literal: true

module Orangelight
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  private

    def config_yaml
      path = Rails.root.join('config', 'orangelight.yml')
      YAML.safe_load(ERB.new(File.read(path)).result, [], [], true)[Rails.env]
    end

    module_function :config, :config_yaml
end
