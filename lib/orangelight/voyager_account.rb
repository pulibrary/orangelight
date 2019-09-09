# frozen_string_literal: true

class VoyagerAccount
  attr_reader :doc
  attr_writer :voyager_ns

  def initialize(string)
    @doc = Nokogiri::XML(string)
  end

  def voyager_ns
    @voyager_ns ||= 'http://www.endinfosys.com/Voyager/myAccount'
  end

  def source_doc
    @doc
  end

  def expiration_date
    date = @doc.xpath('//myac:expirationDate', 'myac' => voyager_ns)
    return nil if date.empty?

    date.text
  end

  def borrowing_blocks
    block_nodes = @doc.xpath('//myac:borrowingBlock', 'myac' => voyager_ns)
    return nil if block_nodes.empty?

    parse_items(block_nodes)
  end

  def has_blocks?
    return true unless borrowing_blocks.nil?
  end

  def failed_renewals?
    return true unless messages.nil?
  end

  def messages
    renew_message_nodes = @doc.xpath('//myac:chargedItem//myac:messages', 'myac' => voyager_ns)
    return nil if renew_message_nodes.empty?

    renew_message_nodes
  end

  def fines_fees
    fine_nodes = @doc.xpath('//myac:fineFee', 'myac' => voyager_ns)
    return nil if fine_nodes.empty?

    parse_items(fine_nodes)
  end

  def demerits
    demerit_nodes = @doc.xpath('//myac:demerit', 'myac' => voyager_ns)
    return nil if demerit_nodes.empty?

    parse_items(demerit_nodes)
  end

  def charged_items
    charged_item_nodes = @doc.xpath('//myac:chargedItem', 'myac' => voyager_ns)
    return nil if charged_item_nodes.empty?

    parse_items(charged_item_nodes)
  end

  def request_items
    request_item_nodes = @doc.xpath('//myac:requestItem', 'myac' => voyager_ns)
    return nil if request_item_nodes.empty?

    parse_items(request_item_nodes)
  end

  def avail_items
    avail_item_nodes = @doc.xpath('//myac:availItem', 'myac' => voyager_ns)
    return nil if avail_item_nodes.empty?

    parse_items(avail_item_nodes)
  end

  def outstanding_hold_requests
    total_holds = 0
    total_holds += avail_items.size unless avail_items.nil?
    total_holds += request_items.size unless request_items.nil?
    total_holds
  end

  protected

    def parse_items(item_nodes)
      items = []
      item_nodes.each do |item|
        items << node_data(item)
      end
      items
    end

    # return hash of any children as "child_node_name" => "text_of_child_node"
    # Special Cases are for messages/renew_status and blocks that may appear in responoses
    # for charged_items, request_items, and avail_items
    def node_data(node)
      node_data = {}
      children = node.children
      children.each do |child|
        if child.name == 'messages'
          node_data[:messages] = node_data(child)
        elsif child.name == 'renewStatus'
          node_data[:renew_status] = node_data(child)
        elsif child.name == 'blocks'
          node_data[:item_blocks] = node_data(child)
        else
          node_data[child.name] = child.text if child.present?
        end
      end
      node_data
    end
end
