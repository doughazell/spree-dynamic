module ApplicationHelper
  def createRomancartXML
    xml = IO.read("romancart-delivery-address1.xml")
    xml_doc  = Nokogiri::XML(xml)
    
    # Order ID
    xml_doc.xpath("/romancart-transaction-data/orderid").first.content = Time.now.to_i
    
    # Price
    xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content = @order.total.to_f
    xml_doc.xpath("/romancart-transaction-data/sales-record-fields/sub-total").first.content = @order.total.to_f
    
    # Item number + Items
    # (Template has 1 item)
    @order.line_items.each do |item|
      # Current item only needs to be cloned after the first
      if item.eql?(@order.line_items.first)
        @current = xml_doc.xpath("/romancart-transaction-data/order-items/order-item").first       
      else
        #xml_item = xml_doc.xpath("/romancart-transaction-data/order-items/order-item").first.clone
        xml_item = @current.clone
        @current = @current.before(xml_item)
        
        #xml_doc.xpath("/romancart-transaction-data/order-items/order-item").first.add_next_sibling(xml_item)
      end
      
      @current.xpath("item-name").first.content = lineItemToOrderItem(item)
    
    end
    
    xml_doc.to_xml
  end
    
end
