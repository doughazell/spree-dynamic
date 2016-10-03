module Helpers
  def showSpecPrice
    width = find(:id, 'width').value
    drop  = find(:id, 'drop').value
    lining = find_field('lining').find('option[selected]')['data-type']
    heading = getHeading
    price = find(:id, 'price-text').text
    
    puts "Width: #{width}"
    puts "Drop: #{drop}"
    puts "Lining: #{lining}"
    puts "Heading: #{heading}"
    
    puts "Price: #{price}"
    
    puts "Capybara.current_driver: #{Capybara.current_driver}"

  end

  def getHeading    
    ids = (3..7)
    selector = ids.each do |id|
      sel = "#variant_id_#{id}"
      if find(sel.to_s).checked?
        break sel
      end
    end
    
    find(selector.to_s)['data-heading']
  end

  def check_alert(text)
    page.evaluate_script "window.original_alert_function = window.alert"
    page.evaluate_script "window.alert = function(msg) { window.lastAlertMsg = msg; }"
    yield
    last_alert_msg = page.evaluate_script "window.lastAlertMsg"
    # 21/7/14 DH: Now clear the message cache for later use to check that subsequent correct actions 
    #             DON'T trigger an alert message
    page.evaluate_script "window.lastAlertMsg = '' "
    
    #last_alert_msg.should == text
    expect(last_alert_msg).to eq(text)
  ensure
    page.evaluate_script "window.alert = window.original_alert_function"
  end
  
=begin
---------------------------------------------------------------------------------
<html>
<body>

<p id=myText>Click the button to demonstrate line-breaks in a new alert box.</p>

<button onclick="myFunction()">Try it</button>

<script>
window.alert = function(msg) { window.lastAlertMsg = msg; }
function myFunction() {
    alert("Hello\nHow are you?");
    
    // See difference to CoffeeScript/jQuery access above
    document.getElementById('myText').innerHTML = window.lastAlertMsg;
}
</script>

</body>
</html>
---------------------------------------------------------------------------------
=end

end
