module Helpers
  def showSpecPrice
    width = find(:id, 'width').value
    drop  = find(:id, 'drop').value
    
    #lining = find_field('lining').find('option[selected]').text
    lining = find_field('lining').find('option[selected]')['data-type']
    
    # CoffeeScript + jQuery:
    #current_heading = ($ '#product-variants input[type="radio"]:checked').data('heading')
    heading = find(:id, 'product-variants').find('input[checked]')['data-heading']
        
    price = find(:id, 'price-text').text
    #price = find(:id, 'price-box').find(:id, 'price-text').text
    
    puts "Width: #{width}"
    puts "Drop: #{drop}"
    puts "Lining: #{lining}"
    puts "Heading: #{heading}"
    
    puts "Price: #{price}"
    
    puts "Capybara.current_driver: #{Capybara.current_driver}"

  end

  def check_alert(text)
    page.evaluate_script "window.original_alert_function = window.alert"
    page.evaluate_script "window.alert = function(msg) { window.lastAlertMsg = msg; }"
    yield
    last_alert_msg = page.evaluate_script "window.lastAlertMsg"
    # 21/7/14 DH: Now clear the message cache for later use
    page.evaluate_script "window.lastAlertMsg = '' "
    
    #last_alert_msg.should == text
    expect(last_alert_msg).to eq(text)
  ensure
    page.evaluate_script "window.alert = window.original_alert_function"
  end
end
