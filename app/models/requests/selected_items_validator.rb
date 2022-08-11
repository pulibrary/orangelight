# frozen_string_literal: true

module Requests
  class SelectedItemsValidator < ActiveModel::Validator
    def mail_services
      ["paging", "pres", "annex", "trace", "on_order", "in_process", "ppl", "lewis", "on_shelf", "annex_in_library"]
    end

    def validate(record)
      record.errors[:items] << { "empty_set" => { 'text' => 'Please Select an Item to Request!', 'type' => 'options' } } unless record.items.size >= 1 && !record.items.any? { |item| defined? item.selected }
      record.items.each do |selected|
        validate_selected(record, selected)
      end
    end

    private

      # rubocop:disable Metrics/MethodLength
      def validate_selected(record, selected)
        return unless selected['selected'] == 'true'
        case selected["type"]
        when 'digitize', 'digitize_fill_in', 'annex_edd', 'marquand_edd', 'clancy_edd', "clancy_unavailable_edd"
          validate_delivery_mode(record: record, selected: selected)
        when 'bd', 'ill'
          validate_ill_on_shelf_or_bd(record, selected, pick_up_phrase: 'delivery of your borrow direct item', action_phrase: 'requested via Borrow Direct')
        when 'recap_no_items'
          validate_recap_no_items(record, selected)
        when 'recap', 'recap_edd', 'recap_in_library', 'clancy_in_library', 'marquand_in_library', 'recap_marquand_edd', 'recap_marquand_in_library'
          validate_offsite(record, selected)
        when 'on_shelf'
          validate_ill_on_shelf_or_bd(record, selected)
        when "help_me"
          true # nothing to validate
        when *mail_services
          validate_pick_up_location(record, selected, selected["type"])
        else
          record.errors[:items] << { selected['mfhd'] => { 'text' => 'Please choose a Request Method for your selected item.', 'type' => 'pick_up' } }
        end
      end
      # rubocop:enable Metrics/MethodLength

      def validate_ill_on_shelf_or_bd(record, selected, pick_up_phrase: 'your selected item', action_phrase: 'Requested')
        return unless validate_item_id(record: record, selected: selected, action_phrase: action_phrase)
        item_id = selected['item_id']
        return if selected['pick_up'].present?

        record.errors[:items] << { item_id => { 'text' => "Please select a pick-up location for #{pick_up_phrase}", 'type' => 'pick_up' } }
      end

      def validate_pick_up_location(record, selected, type)
        return if selected['pick_up'].present?
        id = selected['item_id']
        id = selected['mfhd'] if id.blank?

        record.errors[:items] << { id => { 'text' => "Please select a pick-up location for your selected #{type} item", 'type' => 'pick_up' } }
      end

      def validate_recap_no_items(record, selected)
        return if selected['pick_up'].present? || selected['edd_art_title'].present?

        record.errors[:items] << { selected['mfhd'] => { 'text' => 'Please select a pick-up location for your selected ReCAP item', 'type' => 'pick_up' } }
      end

      def validate_offsite(record, selected)
        return unless validate_item_id(record: record, selected: selected, action_phrase: 'Requested from Off-site Facility')
        validate_delivery_mode(record: record, selected: selected)
      end

      def validate_delivery_mode(record:, selected:)
        item_id = selected['item_id']
        if selected["delivery_mode_#{item_id}"].nil?
          record.errors[:items] << { item_id => { 'text' => 'Please select a delivery type for your selected recap item', 'type' => 'options' } }
        else
          delivery_type = selected["delivery_mode_#{item_id}"]
          record.errors[:items] << { item_id => { 'text' => 'Please select a pick-up location for your selected recap item', 'type' => 'pick_up' } } if delivery_type == 'print' && selected['pick_up'].blank?
          if delivery_type == 'edd'
            record.errors[:items] << { item_id => { 'text' => 'Please specify title for the selection you want digitized.', 'type' => 'options' } } if selected['edd_art_title'].empty?
          end
        end
      end

      def validate_item_id(record:, selected:, action_phrase:)
        return true if selected['item_id'].present?

        record.errors[:items] << { selected['mfhd'] => { 'text' => "Item Cannot be #{action_phrase}, see circulation desk.", 'type' => 'options' } }
        false
      end
  end
end
