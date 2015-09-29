require 'test_helper'

class PermalinksControllerTest < ActionController::TestCase
  setup do
    @permalink = permalinks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:permalinks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create permalink" do
    assert_difference('Permalink.count') do
      post :create, permalink: { venue_id: @permalink.venue_id, venue_origin: @permalink.venue_origin, yield: @permalink.yield }
    end

    assert_redirected_to permalink_path(assigns(:permalink))
  end

  test "should show permalink" do
    get :show, id: @permalink
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @permalink
    assert_response :success
  end

  test "should update permalink" do
    patch :update, id: @permalink, permalink: { venue_id: @permalink.venue_id, venue_origin: @permalink.venue_origin, yield: @permalink.yield }
    assert_redirected_to permalink_path(assigns(:permalink))
  end

  test "should destroy permalink" do
    assert_difference('Permalink.count', -1) do
      delete :destroy, id: @permalink
    end

    assert_redirected_to permalinks_path
  end
end
