require 'test_helper'

class PaymentstatusesControllerTest < ActionController::TestCase
  setup do
    @paymentstatus = paymentstatuses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:paymentstatuses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create paymentstatus" do
    assert_difference('Paymentstatus.count') do
      post :create, paymentstatus: { name: @paymentstatus.name }
    end

    assert_redirected_to paymentstatus_path(assigns(:paymentstatus))
  end

  test "should show paymentstatus" do
    get :show, id: @paymentstatus
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @paymentstatus
    assert_response :success
  end

  test "should update paymentstatus" do
    patch :update, id: @paymentstatus, paymentstatus: { name: @paymentstatus.name }
    assert_redirected_to paymentstatus_path(assigns(:paymentstatus))
  end

  test "should destroy paymentstatus" do
    assert_difference('Paymentstatus.count', -1) do
      delete :destroy, id: @paymentstatus
    end

    assert_redirected_to paymentstatuses_path
  end
end
