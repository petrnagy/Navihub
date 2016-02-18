require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get privacy-policy" do
    get :privacy-policy
    assert_response :success
  end

  test "should get terms-of-use" do
    get :terms-of-use
    assert_response :success
  end

  test "should get data-sources" do
    get :data-sources
    assert_response :success
  end

end
