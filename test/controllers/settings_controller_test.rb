require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  test "should get general" do
    get :general
    assert_response :success
  end

  test "should get location" do
    get :location
    assert_response :success
  end

  test "should get profile" do
    get :profile
    assert_response :success
  end

end
