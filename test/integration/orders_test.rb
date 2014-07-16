require 'test_helper'

#module Spree
class OrdersTest < ActionDispatch::IntegrationTest
  # 7/5/14 DH: The "convention-over-configuration" for the table name comes from the fixtures filename (not the class name)
  #fixtures :spree_orders

=begin
  test "the orders path" do
    # assert true
    
    get "/"
    #assert_response :success
    assert_response 200
    #assert_response :failure
    puts "Cookies from 'get /':"
    puts response.cookies
    
    get "/orders/R573230467"
    
    # 401 = Unauthorized
    # 404 = Not Found
    assert_response 404
    
    get "/login"
    assert_response :success
  end
=end

  test "login and get current order" do
=begin
    # User david logs in
    david = login(:david)
    # User guest logs in
    guest = login(:guest)
 
    # Both are now available in different sessions
    assert_equal 'Welcome david!', david.flash[:notice]
    assert_equal 'Welcome guest!', guest.flash[:notice]
 
    # User david can browse site
    david.browses_site
    # User guest can browse site as well
    guest.browses_site
=end
    
    # 7/5/14 DH: Find order in cart state for user 'doughazell@gmail.com' (but that's in development...hmmm)
    #            
    #user_session = login("doughazell@gmail.com")
    #user_session.post '/login', email: user, password: 'spree123'
    #user_session.get_cart
    
    #user_session.get_order("R573230467")
    #user_session.get "/orders/R573230467"
    #user_session.assert_response 404
    
    get "/login"
    #puts response.body_parts
    #puts response.body
    puts "\n*** 'response.body' removed ***\n\n"
    puts "===================================================================================="
    
    # Get 'authenticity_token' 'input' of the sent 'form'
    input = response.body.scan(/<input name="authenticity_token".*\/>/)
    if input.first
      parts = input.first.split("\"")
      puts "parts: " + parts.to_s
      auth_token_value = parts[5]
      #auth_token_value = parts[5] + "X"
      puts "auth_token_value: " + auth_token_value
    end
    
    puts "===================================================================================="
    puts "===================================================================================="
        
    # 15/5/14 DH: Specifying the host to something 'random' causes 'ActionController::InvalidAuthenticityToken'
    #host!("hazelltree.co.uk")

#debugger
    post_via_redirect "/login", "spree_user[email]" => "spree@example.com", "spree_user[password]" => "spree123", "authenticity_token" => auth_token_value
    #post "/login", "spree_user[email]" => "spree@example.com", "spree_user[password]" => "spree123", "authenticity_token" => auth_token_value, "commit" => "Login"
    
    #puts response.body_parts
    puts "\n*** 'response.body_parts' removed ***\n\n"
    puts "===================================================================================="
    puts "===================================================================================="
    puts flash[:error]
    assert_not_equal "Invalid email or password.", flash[:error]     
    #assert_response 302
    
    puts "#####################################################################################"
    
    get "/orders/R043377643"
    #puts response.body_parts
    puts "\n*** 'response.body_parts' removed ***\n\n"
    assert_response 200
  end
 
  private
 
    module CustomDsl
=begin
      def browses_site
        get "/orders/1934945"
        assert_response :success
        #assert assigns(:products)
      end
=end
      def get_cart
        get "/cart"
        assert_response :success
        
        get "/orders/R573230467"
        
        # 404 = Not Found
        assert_response 404
      end
      
      def get_order(number)
        order_url = "/orders/#{number}"
        puts "Getting: " + order_url
        get order_url
        assert_response :success
      end
    end
    
    def login(user)
      session = open_session do |sess|
        sess.extend(CustomDsl)
        
        sess.get "/admin"
        sess.assert_response 302
        
        #get "/login"
        #assert_response :success
        #assert_equal "/login", sess.path
        
        sess.post '/login', email: user, password: 'spree123'
        #assert_response 302
        sess.assert_response 200
        
        sess.get "/admin"
        # This time it should be 200 since we've logged in...
        sess.assert_response 200
        
        #sess.post "/login", username: user, password: "spree123XXX"
        #sess.assert_redirected_to '/', sess.path
        
      end
      puts session.controller
      session
    end


=begin
    def login(user)
      open_session do |sess|
        sess.extend(CustomDsl)
        u = users(user)
        sess.https!
        sess.post "/login", username: u.username, password: u.password
        assert_equal '/welcome', sess.path
        sess.https!(false)
      end
    end
=end

end
#end
