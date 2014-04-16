require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'RMagick'

namespace :spree_bsc do
  desc 'Loads BSC stock data' 
  task :load => :environment do
    
    #SpreeSample::Engine.load_samples

    puts "\nCurrent Spree Products"
    puts "----------------------"
    products = Spree::Product.find(:all)
    products.each do |product|
      puts product.name
    end
    puts
    
    #abort("\nWTF???\n\n")
    # ----------------------------------------
    
    domain = "www.pongees.co.uk"
    path = "/fabrics/interiors/productcatalogue/690"
    
    total = 0
    next_page = nil
    
    # DEV: Setting '$first_time' to 'true' allows 1 PRODUCT to be added per rake task run
    #      Setting '$first_time' to 'false' means NO PRODUCTS get added.
    $first_time = true
    
    begin
      unless next_page.nil?
        #puts "Nokogiri next_page class: " + next_page.class.to_s 
        path = next_page[0]["href"]
      end
      
      page = Nokogiri::HTML(open("http://#{domain}#{path}"))
    
      silk_names = page.css('div.views-field-field-product-colour a')
      silk_codes = page.css('div.views-field-field-product-code a')
      silk_images = page.css('div.views-field-field-product-image a img')
      
      puts "--- START PAGE ---"
      # The number of products is the size of the 'silk_names' array
      puts silk_names.length
      total += silk_names.length
      
      # --- Find products already in the DB ---
      products.each do |product|
      
        # Uses 'find' from the Ruby Enumerable mixin (since 'silk_names' is a 'Nokogiri::XML::NodeSet' which is an array)
        #if index = silk_names.find_index { |node| node.text =~ /#{product.name.upcase}/ }
        if index = silk_names.find_index { |node| node.text.eql?(product.name.upcase) }

          puts "Found " + product.name + " at index: " + index.to_s
          
          # If we already have it then don't add it again.
          puts silk_names[index].text
          puts silk_codes[index].text
#debugger
          # *** While testing the description + properties then use products ALREADY PRESENT ***
          #silk_path = silk_names[index].attr("href")
          #url = domain + silk_path
          #addDetails(product,url)
          
          silk_names.delete(silk_names[index])
          silk_codes.delete(silk_codes[index])
          silk_images.delete(silk_images[index])
          
        end
      end

      # --- Now add the unadded silks into our system ---
      puts silk_names.length.to_s + ", " + silk_codes.length.to_s

      # --- Dev: Taking first element of each page  ---
      
      #silk = silk_names.first
      #sku  = silk_codes.first
      #image = silk_images.first.attr("src")

      # ----------------------------------------------

      while !silk_names.empty?
        silk  = silk_names.shift
        sku   = silk_codes.shift
        img_url = silk_images.shift.attr("src")
        
        img_colour = getImageColour(img_url)
        
        silk_url = domain + silk.attr("href")
        addProduct(silk.text, sku.text, img_url, img_colour, silk_url)
        
      end

      puts "=== END PAGE ===\n\n"      
      
    end while !(next_page = page.css('div.item-list ul.pager li.pager-next a')).empty?
    
    puts "TOTAL: " + total.to_s

  end
  
  # Green
  # Blue
  # Red
  # Yellow
  # Cyan
  # Magenta
  # Dark
  # Light

  def getImageColour(img_url)
    img = Magick::Image.read(img_url).first

    # Found by '$ rdebug colour.rb':

    # Get Magick::Image of size 1,1
    pix = img.scale(1, 1)

    # Get Magick::Pixel at x=0,y=0
    averageColour = pix.pixel_color(0,0)

    # RGB without Alpha Channel (ie opacity)
    rgbHex = averageColour.to_color(Magick::AllCompliance, false, 8, false)
    red   = rgbHex[1,2].hex
    green = rgbHex[3,2].hex
    blue  = rgbHex[5,2].hex

    #puts "RGB:" + rgbHex
    #puts "Red:" + red.to_s + ",Green:" + green.to_s + ",Blue:" + blue.to_s

    if red < 128 
      colour1 = ["Dark","Green","Blue","Cyan"]
    else
      colour1 = ["Red","Yellow","Magenta","Light"]
    end

    if green < 128
      colour2 = ["Dark","Blue","Red","Magenta"]
    else
      colour2 = ["Green","Cyan","Yellow","Light"]
    end

    if blue < 128
      colour3 = ["Dark","Red","Green","Yellow"]
    else
      colour3 = ["Blue","Magenta","Cyan","Light"]
    end

    #puts "Colour1:"
    #puts colour1
    #puts "\nColour2:"
    #puts colour2
    #puts "\nColour3:"
    #puts colour3


    colour = colour1 & colour2 & colour3

    #puts "\nColour:"
    #puts colour
     
  end
          
  def addProduct(name,sku,img_url,img_colour,silk_url)
    puts
    puts name
    puts sku
    
    # Change the img URL from the list pages to the main page to get a bigger image
    img_url.gsub!("taxonomy_and_product_thumbnail_view","product_image")
    puts img_url
    
    puts img_colour
    puts

=begin
    if $first_time
      puts "--- DOING THIS ONE TIME ONLY... ---"
      $first_time = false
    else
      puts "Not adding product"
      return
    end
=end
    product_attrs = {
      :name              => name,
      :sku               => sku,
      :price             => 12,
      :available_on      => Time.zone.now,
      :shipping_category => Spree::ShippingCategory.find_by_name!("Default")
    }
    
    # **********************************************************************************
    # *** Found mechanism from 'spree_core:spec/models/spree/classification_spec.rb' ***
    # **********************************************************************************
    
    product = Spree::Product.create!(product_attrs)

    taxons = Array.new
    taxons << Spree::Taxon.find_by_name!(img_colour)
    taxons << Spree::Taxon.find_by_name!("Indian Douppion")

    product.taxons << taxons
    
    heading = Spree::OptionType.find_by_presentation!("Heading")
    silk    = Spree::OptionType.find_by_presentation!("Silk")

    product.option_types = [heading, silk]
    product.save!
    
    variant = product.master
    
    variant.images.create!( :attachment => open(img_url) )

    pencilPleat     = Spree::OptionValue.find_by_name!("pencil pleat")
    deepPencilPleat = Spree::OptionValue.find_by_name!("deep pencil pleat")
    doublePleat     = Spree::OptionValue.find_by_name!("double pleat")
    triplePleat     = Spree::OptionValue.find_by_name!("triple pleat")
    eyeletPleat     = Spree::OptionValue.find_by_name!("eyelet pleat")
    
    sample          = Spree::OptionValue.find_by_name!("sample")
    
    variants = [
      {
        :product => product,
        :option_values => [pencilPleat],
        :sku => sku + "-1"
      },
      {
        :product => product,
        :option_values => [deepPencilPleat],
        :sku => sku + "-2"
      },
      {
        :product => product,
        :option_values => [doublePleat],
        :sku => sku + "-3"
      },
      {
        :product => product,
        :option_values => [triplePleat],
        :sku => sku + "-4"
      },
      {
        :product => product,
        :option_values => [eyeletPleat],
        :sku => sku + "-5"
      },
      {
        :product => product,
        :option_values => [sample],
        :sku => sku + "-S"
      }
    ]

    Spree::Variant.create!(variants)
    
    variants.each do |variant|
      product.master.update_attributes!(variant)
    end
    product.master.update_attributes!(:sku => sku)
    
    addDetails(product,silk_url)
    
  end
  
  def addDetails(product, url)
    puts
    puts "Product: " + product.name
    puts "URL: " + url
    
    page = Nokogiri::HTML(open("http://#{url}"))

    desc = page.css('div.product_desc').text
    puts "Description: " + desc
    
    product.description = desc
    product.save!

    page.css('table.silkDetails tr').each do |row|
      
      label = row.css('td.detailsLabel')
      value = row.css('div.field-item')
      
      puts label.text + ": " + value.text
      
      #product.set_property("Type", "Indian Douppion")
      product.set_property(label.text, value.text)
    end
    
    puts
  end

end

=begin
================================================== DUMP ===================================================

    page.css('table.views-view-grid tr td div.views-field-field-product-colour a').each do |el|
    
    page.css('div.taxonomy_colours_titles a').each do |silk_name|
      puts "--------"
      puts "'" + silk_name.text + "'"
      puts "========"
    end

    silk_anchors = page.css('div.taxonomy_colours_titles a')
  
    puts silk_anchors.length
    puts silk_anchors.class
    
    puts silk_anchors[0].text
    puts silk_anchors[0]["href"]
    puts silk_anchors[0].to_s
    
    puts silk_anchors[1].text
    puts silk_anchors[1]["href"]
    
=end
