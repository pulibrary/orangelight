# frozen_string_literal: true
# This class is responsible for displaying the call number and a call
# number browse link
class Holdings::CallNumberLinkComponent < ViewComponent::Base
  def initialize(holding, cn_value)
    @holding = holding
    @cn_value = cn_value
  end

    private

      attr_reader :holding, :cn_value

      def browse_url
        "/browse/call_numbers?q=#{CGI.escape(cn_value)}"
      end

      def original_title
        "Browse: #{cn_value}"
      end
end
