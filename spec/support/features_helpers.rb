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

  # 3/10/16 DH: A sweeeet bit of ruby and capybara...poetry in code...never achieved from tech support work.
  def getHeading    
    # 17/10/20 DH: The variant id's for the first product may vary based on prior deletions affected id
    #ids = (3..7)
    
    #vars = find_all("label").each do |elem| puts elem["for"] end
    vars = find_all("label").map { |elem| elem["for"] }
    
    selector = vars.each do |var|
      #sel = "#variant_id_#{id}"
      var = "##{var}"
      if find(var).checked?
        break var
      end
    end
    
    find(selector)['data-heading']
  end
  
  # 18/10/20 DH: Reducing hard-coded variant ID when selecting non-default heading option
  def getVariantID(pleatStr)

    varID = find_all("label").each do |elem|
      if %r{#{pleatStr}}i.match?(elem.text)
        break elem["for"]
      end
    end

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
