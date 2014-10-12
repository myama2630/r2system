require 'test_helper'

class ContactinfosControllerTest < ActionController::TestCase
  setup do
    @contactinfo = contactinfos(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:contactinfos)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create contactinfo" do
    assert_difference('Contactinfo.count') do
      post :create, contactinfo: { content: @contactinfo.content, mailaddr: @contactinfo.mailaddr, title: @contactinfo.title }
    end

    assert_redirected_to contactinfo_path(assigns(:contactinfo))
  end

  test "should show contactinfo" do
    get :show, id: @contactinfo
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @contactinfo
    assert_response :success
  end

  test "should update contactinfo" do
    patch :update, id: @contactinfo, contactinfo: { content: @contactinfo.content, mailaddr: @contactinfo.mailaddr, title: @contactinfo.title }
    assert_redirected_to contactinfo_path(assigns(:contactinfo))
  end

  test "should destroy contactinfo" do
    assert_difference('Contactinfo.count', -1) do
      delete :destroy, id: @contactinfo
    end

    assert_redirected_to contactinfos_path
  end
end
