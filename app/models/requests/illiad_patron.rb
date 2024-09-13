# frozen_string_literal: true

module Requests
  # Creates patron for Illiad requests
  class IlliadPatron < IlliadClient
    attr_reader :netid, :patron_id, :patron, :attributes

    def initialize(patron)
      super()
      @patron = patron
      @patron_id = patron.patron_id
      @netid = patron.netid
      @attributes = illiad_patron_attributes
    end

    def illiad_patron
      get_json_response("/ILLiadWebPlatform/Users/#{netid}")
    end

    def create_illiad_patron
      return nil if patron.blank?

      patron_response = post_json_response(url: 'ILLiadWebPlatform/Users', body: attributes.to_json)
      if patron_response.blank? && error.dig("ModelState", "UserName") == ["Username #{netid} already exists."]
        patron_response = illiad_patron
      end
      patron_response
    end

    private

      def illiad_patron_attributes
        return {} if status.blank?
        return {} if illiad_status.blank?
        {
          "Username" => netid, "ExternalUserId" => netid, "FirstName" => patron.first_name,
          "LastName" => patron.last_name, "LoanDeliveryMethod" => "Hold for Pickup", "NotificationMethod" => "Electronic",
          "EmailAddress" => patron.active_email, "DeliveryMethod" => "Hold for Pickup",
          "Phone" => patron.telephone, "Status" => illiad_status, "Number" => patron.university_id,
          "AuthType" => "Default", "NVTGC" => "ILL", "Department" => department, "Web" => true,
          "Address" => addresses&.shift, "Address2" => addresses&.join(', '), "City" => "Princeton", "State" => "NJ",
          "Zip" => "08544", "SSN" => patron.barcode, "Cleared" => "Yes", "Site" => "Firestone"
        }
      end

      def addresses
        @addresses ||= patron.address&.split('$')
      end

      def status
        patron.status
      end

      def pustatus
        patron.pustatus
      end

      def title
        patron.title
      end

      def department
        patron.department
      end

      def illiad_status
        return nil if pustatus.blank? || pustatus[0] == 'x'

        if status == "staff"
          illiad_staff_status
        elsif status == "student"
          student_mappings = { "gradetdc" => "GS - Graduate Student", "undergraduate" => "U - Undergraduate", "graduate" => "GS - Graduate Student" }
          student_mappings[pustatus]
        elsif status == "faculty"
          if title.present? && title.include?("Visiting")
            "F - Visiting Faculty"
          else
            "F - Faculty"
          end
        end
      end

      def illiad_staff_status
        if department.present? && department.include?("Library")
          "GS - Library Staff"
        elsif title.present?
          illiad_staff_title_status
        else
          "GS - University Staff"
        end
      end

      # rubocop:disable Metrics/MethodLength
      def illiad_staff_title_status
        if title.include?("Visiting Research")
          "GS - Visiting Research Scholar"
        elsif title.include?("Senior Research Scholar")
          "F - Senior Research Scholar"
        elsif title.include?("Research Scholar")
          "F - Research Scholar"
        elsif title.include?("Senior Professional")
          "F - Senior Professional Specialist"
        elsif title.match?(/Post*doc*Reseach*/i)
          "GS - Post doc Research Associate"
        elsif title.match?(/Post*doc*Fellow*/i)
          "F - Postdoctoral Fellow -- Teaching"
        elsif title.match?(/Visit*Fellow*/i)
          "GS - Visiting Fellow"
        else
          "GS - University Staff"
        end
      end
    # rubocop:enable Metrics/MethodLength
  end
end
