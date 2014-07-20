module Spree
  class BscReq < ActiveRecord::Base
    has_one :line_item, class_name: "Spree::LineItem"
    
    validates_presence_of :width, :drop, :lining, :heading
  
    def self.createBscReqHash(bsc_spec)
      reqs = Hash.new
      bsc_spec.split(',').each do |req|
        category, value = req.split('=')
        reqs[category] = value
      end
      reqs
    end
    
    # 17/7/14 DH: Creating a check to catch dynamic price hacking
    def dynamic_price_invalid?

      params = getPricingParamsHash
      
      #puts
      #params.each {|key, value| puts "#{key}: #{value}"}

=begin
      # ------------------------------- TEST ENV --------------------------------
      if ENV['RAILS_ENV'] == 'test'

        # 17/7/14 DH: Put in during development of dynamic price hack check as a "invalid" dynamic price 
        #             returning "valid" (so that the RSpec model test fails!)    
        if line_item.price == 69
          return false # ie OK
        end
        
        # 17/7/14 DH: Put in during development of dynamic price hack check as a "valid" dynamic price 
        #             returning "invalid" (so that the RSpec model test fails!)
        if line_item.price == 144
          return true # ie don't fink so...boooard's don't fight back...
        end
      end # END: if ENV['RAILS_ENV'] == 'test'
      # ------------------------------ END: TEST ENV -----------------------------
=end
      
      # Put in dynamic curtain pricing algorithm here...

      # product.js.coffee:
      #  Spree.calcNumberOfWidths ( width )
      #  Spree.calcPrice ( drop )
      #   Spree.recalcPriceOnLining (lining)
    
      calc_width = width + params[:returns_addition]
      
      #heading = "pencil pleat"
      #params[:pencil_pleat_multiple]
      multiple = params["#{heading.gsub(/ /,'_')}_multiple".to_sym]
      
      calc_width *= multiple
      calc_width += params[:side_hems_addition]
      number_of_widths = (calc_width / params[:fabric_width]).ceil
      
      cutting_len = drop + params[:turnings_addition]
      if (params[:pattern_repeat] > 0)
        repeat_len_multiple = (cutting_len / params[:pattern_repeat]).ceil
        cutting_len = params[:pattern_repeat] * repeat_len_multiple
      end
      
      # Convert to meters to calc price based on "£/m"
      required_fabric_len = cutting_len * number_of_widths / 100
      
      # Multiply by 100 to convert to pence, round to nearest penny, then convert back to pounds by dividing by 100, simples...
      price = (required_fabric_len * params[:price_p_m] * 100).round / 100
      
      #lining = "cotton"
      #params[:cotton_lining]
      #params[:cotton_lining_labour]
      lining_cost        = required_fabric_len * params["#{lining}_lining".to_sym]
      lining_labour_cost = required_fabric_len * params["#{lining}_lining_labour".to_sym]
      
      total_price = price + lining_cost + lining_labour_cost
      total_price = ((total_price * 100).round / 100).round(2)

      if line_item.price == total_price
        return false # ie OK
      else
        return true # ie invalid
      end
      
    end
    
    def getPricingParamsHash
      params = Hash.new

=begin
      product = Spree::Product.find_by_id(67)
      image = product.images[0]
      imageID = image.id
      imageViewID = image.viewable_id
      puts "\nProduct image ID: #{imageID} (viewable_id of #{imageViewID} same as the master variant ID of #{product.master.id})"
=end

      params[:price_p_m] = Spree::Variant.find_by_id(line_item.variant_id).price.to_f

      patternRepeat = 0
      # --- First make sure the Property Type has been added to the DB ---
      if propertyType = Spree::Property.find_by_name("Pattern Repeat")
        # --- Then check whether this product requires the Pattern Repeat pricing ---
        if ( property = line_item.product.product_properties.find_by_property_id(propertyType.id) )
          patternRepeat = property.value
        end 
      end
      params[:pattern_repeat]             = patternRepeat

      params[:returns_addition]           = Spree::Config[:returns_addition]
      params[:side_hems_addition]         = Spree::Config[:side_hems_addition]
      params[:turnings_addition]          = Spree::Config[:turnings_addition]

      params[:pencil_pleat_multiple]      = Spree::Config[:pencil_pleat_multiple]
      params[:deep_pencil_pleat_multiple] = Spree::Config[:deep_pencil_pleat_multiple]
      params[:double_pleat_multiple]      = Spree::Config[:double_pleat_multiple]
      params[:triple_pleat_multiple]      = Spree::Config[:triple_pleat_multiple]
      params[:eyelet_pleat_multiple]      = Spree::Config[:eyelet_pleat_multiple]

      params[:fabric_width]               = Spree::Config[:fabric_width]

      params[:cotton_lining]              = Spree::Config[:cotton_lining]
      params[:blackout_lining]            = Spree::Config[:blackout_lining]
      params[:thermal_lining]             = Spree::Config[:thermal_lining]

      params[:cotton_lining_labour]       = Spree::Config[:cotton_lining_labour]
      params[:blackout_lining_labour]     = Spree::Config[:blackout_lining_labour]
      params[:thermal_lining_labour]      = Spree::Config[:thermal_lining_labour]

      params
    end
    
    # 3/5/14 DH: First idea to prevent a row being added to 'spree_bsc_reqs' with a missing value.
    #            Solved by adding 'not null' to each column in the DB with the 'AddNotNullToSpreeBscReq' migration.
=begin
    def valid?(context = nil)
      puts "#{line_item.bsc_req} : #{line_item.bsc_req.inspect}"
      return false if line_item.bsc_req.width.nil?
      return false if line_item.bsc_req.drop.nil?
      return false if line_item.bsc_req.lining.nil?
      return false if line_item.bsc_req.heading.nil?
      true
    end
=end
  end
end