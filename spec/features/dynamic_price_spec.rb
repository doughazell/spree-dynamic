require 'spec_helper'

describe 'order_content', :type => :feature do

  it "can NOT add curtain spec of 'width=144,drop=69,lining=cotton,heading=pencil pleat' with hacked price" do |example|
    puts "\n--TEST--: #{example.description}"

    Capybara.current_driver = :webkit
    #Capybara.current_driver = :selenium

    #visit "/products/oasis"
    #string = "oasis"
    visit "/products/adonis-blue"
    string = "adonis-blue"
    
    #expect(page).to have_content "OASIS"

    
    # "%r{...}" creates a regular expression (normally specified by "/.../")
    # The "i" after the closing delimiter is used to ignore the case when matching text
    
    #expect(page.body).to match( %r{#{string}}i )
    expect(page.body).to match( /#{string}/i )
    
    fill_in('width', :with => '144')
    fill_in('drop', :with => '69')
    
    # Select it and then another field to active 'onBlur'
    find(:id, 'drop').click
    find_field('lining').click
    
    showSpecPrice
    
    check_alert("You need to accept that measurements are 'cm'") {find(:id, 'add-to-cart-button').click}
    
    # 'capybara-webkit' depends on 'capybara (< 2.4.0, >= 2.0.2)' but 'accept_alert' added in 2.4.0!
=begin
    message = accept_alert do
      find(:id, 'add-to-cart-button').click
    end
    expect(message).to eq("You need to accept that measurements are 'cm'")
=end

    check('cm_measurements')
    
    # Alter the correct dynamic price
    # (Correct price for this spec is "£53.40" and 'Spree::BscReq.dynamic_price_invalid?' uses 'Float.floor')
    Spree::BscReq.alterDynamicPrice(-0.41)
  
    #expect(find(:id, 'add-to-cart-button').click).to raise_error "The dynamic price is incorrect"
    find(:id, 'add-to-cart-button').click
  
    # 21/7/14 DH: Need to sleep for 3 secs to allow AJAX to alter link text
    sleep 2
      
    #expect(find(:id, 'page-link-to-cart').text).to eq("Cart: (Empty)")
    expect(find(:id, 'page-link-to-cart').text).to eq("The dynamic price is incorrect")

    # 10/10/16 DH: Need to check mechanism for not adding incorrect price to orig spree cart
    expect(find(:id, 'link-to-cart').text).to eq("Cart: (Empty)")
#debugger
    Spree::BscReq.clearDynamicPriceAlteration

    # 12/10/16 DH: Well it wasn't the state of Capybara that needed to be changed prior to resubmitting
    #find(:id, 'drop').click
    #find_field('lining').click

    # 30/9/14 DH: Checking the 'Spree::BscReq.clearDynamicPriceAlteration' works
    find(:id, 'add-to-cart-button').click
    sleep 2
    expect(find(:id, 'page-link-to-cart').text).to_not eq("The dynamic price is incorrect")

  end

  #it "can add curtain spec of 'width=144,drop=69,lining=cotton,heading=pencil pleat'", :js => true do |example|
  it "can add curtain spec of 'width=144,drop=69,lining=cotton,heading=pencil pleat'" do |example|
    puts "\n--TEST--: #{example.description}"

    #Capybara.default_driver = :selenium
    Capybara.current_driver = :webkit
    Capybara.javascript_driver = :webkit

    #visit "/products/oasis"
    #string = "oasis"
    visit "/products/adonis-blue"
    string = "adonis-blue"
    
    #expect(page).to have_content "OASIS"
    
    expect(page.body).to match(%r{#{string}}i)
    
    fill_in('width', :with => '144')
    fill_in('drop', :with => '69')
    
    # Select it and then another field to active 'onBlur'
    find(:id, 'drop').click
    find_field('lining').click
    
    showSpecPrice
    
    check_alert("You need to accept that measurements are 'cm'") {find(:id, 'add-to-cart-button').click}
    check('cm_measurements')
    
    find(:id, 'add-to-cart-button').click
    
    # 21/7/14 DH: Need to sleep for 3 secs to allow AJAX to alter link text
    sleep 3
    expect(find(:id, 'page-link-to-cart').text).to_not eq("Cart: (Empty)")

  end

  it "can add curtain spec of 'width=200,drop=100,lining=cotton,heading=eyelet pleat'" do |example|
    puts "\n--TEST--: #{example.description}"

    Capybara.current_driver = :webkit
    Capybara.javascript_driver = :webkit

    #visit "/products/willow"
    #string = "willow"
    visit "/products/adonis-blue"
    string = "adonis-blue"
    
    expect(page.body).to match(%r{#{string}}i)
    
    fill_in('width', :with => '200')
    fill_in('drop', :with => '100')
    
    # Select it and then another field to active 'onBlur'
    find(:id, 'drop').click
    find_field('lining').click
    
    #puts "# Need to obtain variant_id from page (rather than hard-coded in: #{example.file_path})...!!!"
    #choose('variant_id_14')
    choose(getVariantID("Eyelet Pleat"))
    
    showSpecPrice
    
    check_alert("You need to accept that measurements are 'cm'") {find(:id, 'add-to-cart-button').click}
    check('cm_measurements')
    
    find(:id, 'add-to-cart-button').click
    
    # 21/7/14 DH: Need to sleep for 3 secs to allow AJAX to alter link text
    sleep 3
    expect(find(:id, 'page-link-to-cart').text).to_not eq("The dynamic price is incorrect")

  end


end
