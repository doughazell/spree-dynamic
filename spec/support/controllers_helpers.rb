# 17/7/15 DH: This is run outside of a test but inside the 'describe' so can not be in the Helpers module in order to be found!
#             (for some object name mangline reason...)

#module Helpers

def getOrder
  order = nil
  begin
  
    # 18/7/15 DH: Don't know ID since it's just a sequence table and want 'ActiveRecord::RecordNotFound' error
    order = Spree::Order.first

  rescue ActiveRecord::RecordNotFound => e
    puts "\nPlease run 'RAILS_ENV=development rspec spec/features/dynamic_price_spec.rb' first on a bare-bones DB"
    puts "After:"
    puts "      rake db:create"
    puts "      rake db:migrate"
    puts "      rake spree_bsc:load"
    puts "      rake spree_auth:admin:create"
    abort("\n")
  end
  
  order
end

def printLineItems(order)
  return unless order
  itemNum = 0
  itemTotal = order.line_items.count
  puts
  order.line_items.each do |item|
    itemNum += 1
    print "Order: #{order.number} - (#{itemNum}/#{itemTotal} items) #{Spree::Variant.find_by_id(item.variant_id).name}"
    if item.bsc_req
      puts ", bsc_req.id: #{item.bsc_req.id}"
    else
      puts
    end
  end

end

module Helpers

  def chgOrderID(romancartxml, order)
    xml = romancartxml.sub("<?xml version='1.0' encoding='UTF-8'?>", "")
    xml_doc  = Nokogiri::XML(xml)
  
    rc_orderid = xml_doc.xpath("/romancart-transaction-data/orderid")
    puts "ROMANCARXML orderid: #{rc_orderid.text}"
    
    tmp_order = Spree::Order.find_by(number: rc_orderid.text)
    if (tmp_order && tmp_order.complete?)
      puts "orderid: #{rc_orderid.text} has already been taken to completion"
      
      new_num = Spree::Order.new.generate_number(prefix: "RC")
      puts "New num: #{new_num}"
      
      # 20/7/15 DH: Now need to find another order that is not complete
      order = Spree::Order.where("state != ? AND total > ?", "complete",0).first
      
      xml_doc.xpath("/romancart-transaction-data/orderid").first.content = new_num
    end
    [xml_doc, order]
  end

  def chgTotalPrice(xml_doc, order)
    total_price = xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content
    puts "Total Price (in file): " + total_price
    
    if order
      xml_doc.xpath("/romancart-transaction-data/sales-record-fields/total-price").first.content = order.total.to_s      
    else
      puts "============================================================================="
      puts "You probably don't have any cart orders"
      puts "Try running 'RAILS_ENV=development rspec spec/features/dynamic_price_spec.rb'"
      puts "          + 'config.use_transactional_fixtures = false'"
      puts "============================================================================="
    end
    
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
      #rc_price = rc_prices[num].text
      
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