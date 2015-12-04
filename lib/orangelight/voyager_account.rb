#require 'nokogiri'

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

  def fines_fees
    # not sure if "finesFee" is right element name 
    fine_nodes = @doc.xpath('//myac:finesFee', 'myac'=> @@voyager_ns)
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
    items = parse_items(request_item_nodes)
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
  def node_data(node)
    node_data = Hash.new
    children = node.children
    children.each do |child|
      node_data[child.name] = child.text
    end
    node_data
  end
end