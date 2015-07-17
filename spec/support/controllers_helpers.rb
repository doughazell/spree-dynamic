module Helpers
  def chgTotalPrice(romancartxml, order)
    xml = romancartxml.sub("<?xml version='1.0' encoding='UTF-8'?>", "")
    xml_doc  = Nokogiri::XML(xml)
    
    total_price = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content
    puts "Total Price (in file): " + total_price
    
    xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content = order.total.to_s      
    
    total_price = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content
    puts "Total Price (from order #{order.number}, ID: #{order.id}): " + total_price
    
    xml_doc
  end
  
  def chgItems(xml_doc, order)
    rc_items = xml_doc.xpath("/romancart-transaction-data/order-items/order-item/item-name")
    rc_prices = xml_doc.xpath("/romancart-transaction-data/order-items/order-item/price")
    
    if order.line_items.count != rc_items.count
      puts "Order line_items #{order.line_items.count} does not match XML items #{rc_items.count}"
      #return false
    end

    # --- ITEMS ---
    # 14/6/14 DH: The item order needs to match which is not necessarily an invalid feedback (so permutation not combination match)
    num = 0
    order.line_items.each do |item|
    
      # 14/6/14 DH: Spree::DynamicHelper method
      order_item = lineItemToOrderItem(item)
#debugger
      rc_item = rc_items[num].text
      rc_price = rc_prices[num].text
      
      if !rc_item.eql?(order_item)
        puts "Order item: '#{order_item}' does not match XML item '#{rc_item}'"
        xml_doc.xpath("/romancart-transaction-data/order-items/order-item/item-name")[num].content = order_item
        #return false
      else
        puts "We're good for XML item '#{rc_item}'"
      end
      
      num += 1
    end
    
    xml_doc
  end
end