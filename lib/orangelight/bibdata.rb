module Bibdata
  class << self
    def get_patron(id)
      return false unless id
      begin
        patron_record = Faraday.get "#{ENV['bibdata_base']}/patron/#{id}"
      rescue Faraday::Error::ConnectionFailed
        Rails.logger.info("Unable to connect to #{ENV['bibdata_base']}")
        return false
      end

      if patron_record.status == 403
        Rails.logger.info('403 Not Authorized to Connect to Patron Data Service at '\
                    "#{ENV['bibdata_base']}/patron/#{id}")
        return false
      end
      if patron_record.status == 404
        Rails.logger.info("404 Patron #{id} cannot be found in the Patron Data Service.")
        return false
      end
      if patron_record.status == 500
        Rails.logger.info('Error Patron Data Service.')
        return false
      end
      patron = JSON.parse(patron_record.body).with_indifferent_access
      Rails.logger.info(patron.to_hash.to_s)
      patron
    end
  end
end
