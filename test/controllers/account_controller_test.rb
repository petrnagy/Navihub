require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get logout" do
    get :logout
    assert_response :success
  end

  test "should get register" do
    get :register
    assert_response :success
  end

  test "should get google_login" do
    get :google_login
    assert_response :success
  end

  test "should get facebook_login" do
    get :facebook_login
    assert_response :success
  end

  test "should get twitter_login" do
    get :twitter_login
    assert_response :success
  end

end
