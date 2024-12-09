# frozen_string_literal: true
Rails.application.config.after_initialize do
  HealthMonitor.configure do |config|
    config.cache

    config.solr.configure do |c|
      c.url = Blacklight.default_index.connection.uri.to_s
    end

    config.file_absence.configure do |file_config|
      file_config.filename = "public/remove-from-nginx"
    end

    config.add_custom_provider(AeonStatus)
    config.add_custom_provider(BibdataStatus)
    config.add_custom_provider(IlliadStatus)
    config.add_custom_provider(ScsbStatus)
    config.add_custom_provider(StackmapStatus)

    # Make this health check available at /health
    config.path = :health

    config.error_callback = proc do |e|
      Rails.logger.error "Health check failed with: #{e.message}" unless e.is_a?(HealthMonitor::Providers::FileAbsenceException)
    end
  end
end
