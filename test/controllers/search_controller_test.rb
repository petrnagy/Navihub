require 'test_helper'

class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get find" do
    get :find
    assert_response :success
  end

  test "should get empty" do
    get :empty
    assert_response :success
  end

end
