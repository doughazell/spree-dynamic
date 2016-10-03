# "$ ->" same as "jQuery ->" since CoffeeScript using jQuery...you beauty...feel the Javascript leverage...
$ ->
  # Use this to store values in the DOM
  exports = this

  ###  
  ---------------------------------------------------------------------------------------------
  [Orig Spree stuff removed]
  ---------------------------------------------------------------------------------------------
  ###
  
  radios = ($ '#product-variants input[type="radio"]')

  ###
  =================== BSC dynamic pricing =====================
  ###

  # ------------------ Params (from initializer file) stored in web page via 'data-' attribute and used by jQuery --------------
  # Following numbers are in 'cm'
  returns_addition   = ($ '#bsc-pricing').data('returns-addition')
  side_hems_addition = ($ '#bsc-pricing').data('side-hems-addition')
  turnings_addition  = ($ '#bsc-pricing').data('turnings-addition')

  fabric_width   = ($ '#bsc-pricing').data('fabric-width')
  repeat_len = ($ '#bsc-pricing').data('pattern-repeat')     
  # ----------------------------------------------------------------------------------------------------------------------------- 

  # Orig user specified values
  curtain_width = 0
  curtain_drop  = 0
  lining          = ""
  current_heading = ""

  # These are the values assigned when the 'width' + 'drop' fields are assigned (so needs to be declared above the function definition)
  number_of_widths = 0
  required_fabric_len = 0
  price = 0
  total_price = 0

  Spree.getCurrentMultiple = ->
    current_heading = ($ '#product-variants input[type="radio"]:checked').data('heading')
    
    # Replace the whitespace between the heading words, in the variant list, with hyphens, in order to access the stored data
    hyphened_heading = current_heading.replace(/\ /g, '-')
    hyphened_heading += "-multiple"
    # Implicit return of last value
    current_multiple_val = ($ '#bsc-pricing').data(hyphened_heading)    
    # ---

  Spree.calcNumberOfWidths = (width) ->
    width += returns_addition
    
    multiple = Spree.getCurrentMultiple()
    
    required_width = width * multiple
    required_width += side_hems_addition
    # We always need to round up, NOT TO NEAREST INT, so 2.1 needs to be 3 not 2!
    number_of_widths = Math.ceil(required_width / fabric_width)
    
    #($ '#price-text').text(number_of_widths)
    # ---

  Spree.recalcPriceOnLining = (lining) ->
    lining_costing        = ($ '#bsc-pricing').data(lining+'-lining')
    console.log("Lining costing:" + lining_costing)
    lining_labour_costing = ($ '#bsc-pricing').data(lining+'-lining-labour')
    console.log("Lining labour costing:" + lining_labour_costing)
    
    lining_cost        = required_fabric_len * lining_costing
    lining_labour_cost = required_fabric_len * lining_labour_costing
    console.log("Lining labour cost:" + lining_labour_cost)
    
    console.log("Price: " + price)
    total_price = price + lining_cost + lining_labour_cost
    console.log("Total price (before rounding): " + total_price)
    total_price = ((Math.round(total_price * 100)) / 100).toFixed(2)
    console.log("Total price: " + total_price)
    price_text = String.fromCharCode('163') + total_price
    console.log("Price text: " + price_text)
    
    ($ '#price-text').text(price_text)
        
    # ---
  
  Spree.calcPrice = (drop) ->
    cutting_len = drop + turnings_addition
    console.log("Cutting len: " + cutting_len)
    
    # -----------------------------
    # *** PATTERN REPEAT FABRIC ***
    # -----------------------------
    # If the curtain is pattern repeat (id by repeat data-attrib value not zero, set by 'views/spree/products/show.html.erb')
    # then divide cutting_len by repeat_len and round up.
    if repeat_len > 0
      repeat_len_multiple = Math.ceil(cutting_len / repeat_len)
      
      console.log("----------------------------")
      console.log("repeat_len:" + repeat_len)
      console.log("repeat_len_multiple:" + repeat_len_multiple)
      console.log("cutting_len:" + cutting_len)
      
      cutting_len  = repeat_len * repeat_len_multiple
      console.log("cutting_len:" + cutting_len)
      console.log("----------------------------")
    # ---
    
    # Convert to meters to calc price based on "£/m"
    required_fabric_len = cutting_len * number_of_widths / 100
    console.log("Req fabric len: " + required_fabric_len)

    price_string = ($ '#product-variants input[type="radio"]:checked').data('price')
    console.log("Price string: " + price_string)
    
    # Remove the preceding '£' sign
    #price_string.replace(/&pound;/g, ' ')
    price_per_meter = price_string.substring(1)
    
    console.log("Price per meter: " + price_per_meter)

    # Multiply by 100 to convert to pence, round to nearest penny, then convert back to pounds by dividing by 100, simples...
    price = (Math.round(required_fabric_len * price_per_meter * 100)) / 100
    total_price = price
    console.log("Price (in 'calcPrice'): " + price)
    
    lining = ($ '#lining option:selected').data('type')
    Spree.recalcPriceOnLining (lining)
    # ---
    
  # CoffeeScript block comments are passed through to compiled Javascript (single line comments are not)
  ###
  ========================================= 'jQuery' DOM event binding in CoffeeScript ========================================
                                           |------------------------------------------|
                                                (A little bit of ASCII-art for you)
                                                     Apparantly autistic people, 
                                                       like to line things up.
  
                                                       "Welcome to the Matrix"
                                             The mental projection of your digital self.
  
                                                                 :-)
  ###
  
  # 8/10/13 DH: I feel I'm finally on home ground...ye haaa! :) That's only taken me 8 years since cutting the bootloader code...

  # ------------------ Width ------------------
  $(document).on('blur', '#width', ( ->
    console.log("Handling 'onBlur' for #width")
    curtain_width = width = (Number) @value
    Spree.calcNumberOfWidths (width)
    drop  = (Number) ($ '#drop').val()
    console.log("Drop:" + drop)
    if drop > 0
      Spree.calcPrice (drop)
    # ---
  ))
  # ---
  
  # ----------------- Drop ------------------  
  $(document).on('blur', '#drop', ( ->
    curtain_drop = drop = (Number) @value
    Spree.calcPrice (drop)
  ))
  # ---

  # ----------------- Lining ------------------    
  $(document).on('click', '#lining', ( ->
    lining_id = @value

    lining = ($ '#lining option:selected').data('type')
    Spree.recalcPriceOnLining (lining)
  ))
  # ---

  # ----------------- Heading ------------------      
  radios.click (event) ->    
    width = (Number) ($ '#width').val()
    drop  = (Number) ($ '#drop').val()
    Spree.calcNumberOfWidths ( width )
    Spree.calcPrice ( drop )
    
    # ---

  # ----------------- Submit ------------------    
  $(document).on('click', '#add-to-cart-button', ( ->
    unless total_price > 0
      return false
    # ---
    
    # Send the dynamic price back to the server via '#price' <input> tag to the <form>
    ($ '#price').val(total_price)
    
    spec = "width=" + curtain_width + ",drop=" + curtain_drop + ",lining=" + lining + ",heading=" + current_heading
    ($ '#spec').val(spec)
    
    unless ($ '#cm_measurements').is(':checked')
      alert "You need to accept that measurements are 'cm'"
      false
    # --- 

  ))
  # ---

  # ----------------- On-load ------------------
  #<%# debugger %> - Needs '.erb' appended onto filename extension
  # Gets current state of asset pipeline when this file is compiled (which is based on filename extension stack)
  #
  #erbText = <% "product ID: #{@product.master.id} = #{ @product.price }"  %>
  #erbText = "WTF???"
  #($ '#price-text').text(erbText)
  
# ------------------------------------ DUMP -------------------------------------
#    ($ '#price-text').text(jQuery.type(price_per_meter))
#    ($ '#price-text').text(($ '#product-variants input[type="radio"]:checked').attr('data-price')) 
#    ($ '#price-text').text(($ '#product-variants input[type="radio"]:checked').data('price'))    
