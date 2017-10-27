module Spree
  class BscReq < ActiveRecord::Base
    # 7/6/15 DH: Altered FK place of LineItem<->BscReq + Need migration to add FK to BscReq:
    #            $ rails g migration AddLineItemIDToSpreeBscReqs spree_line_item:references
    #has_one :line_item, class_name: "Spree::LineItem"
    
    #belongs_to :line_item, class_name: "Spree::LineItem", foreign_key: "spree_line_item_id"
    belongs_to :line_item, class_name: "Spree::LineItem"
    
    validates_presence_of :width, :drop, :lining, :heading
    
    # 18/6/15 DH: Creating an array for any BSC Req errors since using 'errors' gets wiped before ActiveRecord validations
    class_attribute :msgs
    
    # 19/6/15 DH: Now not using 'bsc_req_id = -1' to indicate error since FK now in BscReq
    class_attribute :price_error
   
    def self.createBscReqHash(bsc_spec)
      reqs = Hash.new
      bsc_spec.split(',').each do |req|
        category, value = req.split('=')
        reqs[category] = value
      end
      reqs
    end
    
    # 22/7/14 DH: Created to simulate a "hacked" dynamic price in an RSpec features test
    def self.alterDynamicPrice(alteration)
      if ENV['RAILS_ENV'] == 'test' || ENV['RAILS_ENV'] == 'development'
        cattr_accessor :price_alteration
        @@price_alteration = alteration

        # 12/10/16 DH: Checking to see whether this was called from an auto RSpec test (Ruby Kernel::caller)
        if (caller.grep(/rspec/).size > 0)
          cattr_accessor :rspec_alteration
          @@rspec_alteration = true
        end
      end
    end
    
    def self.clearDynamicPriceAlteration
      if ENV['RAILS_ENV'] == 'test' || ENV['RAILS_ENV'] == 'development'
        # 30/9/14 DH: Use a Ruby method to make Ruby method 'bsc_req.respond_to?(:price_alteration)' return false
        if self.respond_to?(:price_alteration)
          undef :price_alteration
          #@@price_alteration = 0
        end
                
        if self.respond_to?(:rspec_alteration)
          undef :rspec_alteration
        end

      end
    end
    
    # 17/7/14 DH: Creating a check to catch dynamic price hacking
    def dynamic_price_invalid?

      params = getPricingParamsHash
      
      #puts
      #params.each {|key, value| puts "#{key}: #{value}"}

      # ----------------------------------------------
      # product.js.coffee:
      #  Spree.calcNumberOfWidths ( width )
      #  Spree.calcPrice ( drop )
      #   Spree.recalcPriceOnLining (lining)
      # ----------------------------------------------

      calc_width = width + params[:returns_addition]
      
      # -------------------------------
      # heading = "pencil pleat"
      # params[:pencil_pleat_multiple]
      # -------------------------------
      multiple = params["#{heading.gsub(/ /,'_')}_multiple".to_sym]
      
      calc_width *= multiple
      calc_width += params[:side_hems_addition]
      # 3/10/16 DH: Needed to explicitly cast to Float via 'to_f' with ruby-2.2.2 before calling 'ceil'
      number_of_widths = (calc_width.to_f / params[:fabric_width]).ceil
      
      cutting_len = drop + params[:turnings_addition]
      if (params[:pattern_repeat] > 0)
        # 3/10/16 DH: Needed to explicitly cast to Float via 'to_f' with ruby-2.2.2 before calling 'ceil'
        repeat_len_multiple = (cutting_len.to_f / params[:pattern_repeat]).ceil
        cutting_len = params[:pattern_repeat] * repeat_len_multiple
      end
      
      # Convert to meters to calc price based on "£/m"
      required_fabric_len = Float(cutting_len * number_of_widths)/100
      
      # Multiply by 100 to convert to pence, round to nearest penny, then convert back to pounds by dividing by 100, simples...
      price = Float((required_fabric_len * params[:price_p_m] * 100).round) / 100
      
      # ------------------------------
      # lining = "cotton"
      # params[:cotton_lining]
      # params[:cotton_lining_labour]
      # ------------------------------
      lining_cost        = Float(required_fabric_len * params["#{lining}_lining".to_sym])
      lining_labour_cost = Float(required_fabric_len * params["#{lining}_lining_labour".to_sym])
      
      total_price = price + lining_cost + lining_labour_cost
      total_price = Float((total_price * 100).round) / 100
      
      # 8/8/14 DH: The RSpec 'features/dynamic_price_spec.rb' uses 'self.alterDynamicPrice(alteration)'
      #            and runs under the 'test' env so doesn't need this "trap"
      #
      # 11/10/16 DH: Not if run with 'RAILS_ENV=development rspec spec/features/dynamic_price_spec.rb' !!!
      #
      # ...yup that's just taken me most of the day doing the Rails thing or narrowing down the search space of:
      #    RSpec + Ruby-2.2.2 undef + ActiveRecord Associations + Debugger issues missing Javascript response + 
      #    Class vs Object values
=begin
      if ENV['RAILS_ENV'] == 'development'
        if line_item.price == 53.40
          return true # ie DELIBERATELY INVALID...!!!
        end
      end # END: if ENV['RAILS_ENV'] == 'development'
=end

      # 21/7/14 DH: Match the prices to the nearest pound
      
      # 8/8/14 DH: Potentially this could reject a valid price due to rounding error since £52.99 would be 
      #            considered valid for £53.00 by a human!
      #   (Anyway the dynamic price algorithm is only valid in Kendall-land so potential bug just noted!)
      if (line_item.price.floor == total_price.floor)
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