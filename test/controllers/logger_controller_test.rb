require 'test_helper'

class LoggerControllerTest < ActionController::TestCase
  test "should get js" do
    get :js
    assert_response :success
  end

end
