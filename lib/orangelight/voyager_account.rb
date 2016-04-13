class VoyagerAccount

  attr_reader :doc

  @@voyager_ns = 'http://www.endinfosys.com/Voyager/myAccount'

  def initialize(string)
    @doc = Nokogiri::XML(string)
  end

  def source_doc
   @doc
  end

  def expiration_date
    date = @doc.xpath('//myac:expirationDate', 'myac'=> @@voyager_ns)
    return nil if date.empty?
    date.text
  end

  def borrowing_blocks
    block_nodes = @doc.xpath('//myac:borrowingBlock', 'myac'=> @@voyager_ns)
    return nil if block_nodes.empty?
    blocks = parse_items(block_nodes)
  end

  def has_blocks?
    return true if !borrowing_blocks.nil?
  end

  def fines_fees
    # not sure if "finesFee" is right element name 
    fine_nodes = @doc.xpath('//myac:fineFee', 'myac'=> @@voyager_ns)
    return nil if fine_nodes.empty?
    fines = parse_items(fine_nodes)
  end

  def demerits
    demerit_nodes = @doc.xpath('//myac:demerit', 'myac'=> @@voyager_ns)
    return nil if demerit_nodes.empty?
    demerits = parse_items(demerit_nodes)
  end

  def charged_items
    charged_item_nodes = @doc.xpath('//myac:chargedItem', 'myac'=> @@voyager_ns)
    return nil if charged_item_nodes.empty?
    items = parse_items(charged_item_nodes)
  end

  def request_items
    request_item_nodes = @doc.xpath('//myac:requestItem', 'myac'=> @@voyager_ns)
    return nil if request_item_nodes.empty?
    items = parse_items(request_item_nodes)
  end

  def avail_items
    avail_item_nodes = @doc.xpath('//myac:availItem', 'myac'=> @@voyager_ns)
    return nil if avail_item_nodes.empty?
    items = parse_items(avail_item_nodes)
  end

  def outstanding_hold_requests
    total_holds = 0
    unless avail_items.nil?
      total_holds = total_holds + avail_items.size
    end
    unless request_items.nil?
      total_holds = total_holds + request_items.size
    end
    total_holds
  end

  protected
  def parse_items(item_nodes)
    items = Array.new
    item_nodes.each do |item|
      items << node_data(item)
    end
    items
  end

  # return hash of any children as "child_node_name" => "text_of_child_node"
  # Special Cases are for messages/renew_status and blocks that may appear in responoses
  # for charged_items, request_items, and avail_items
  def node_data(node)
    node_data = Hash.new
    children = node.children
    children.each do |child|
      if child.name == 'messages'
        node_data[:messages] = node_data(child)
      elsif child.name == 'renewStatus'
        node_data[:renew_status] = node_data(child)
      elsif child.name == 'blocks'
        node_data[:item_blocks] = node_data(child)
      else
        unless child.blank?
          node_data[child.name] = child.text
        end
      end
    end
    node_data
  end

end