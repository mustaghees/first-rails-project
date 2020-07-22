require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get user_registration_url
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to new_user_session_path
  end

  test "should redirect edit when not logged in" do
    get edit_user_registration_path(@user)
    assert_not flash.empty?
    assert_redirected_to new_user_session_url
  end

  test "should redirect update when not logged in" do
    patch user_registration_path, params: { user: { name: @user.name, email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to new_user_session_url
  end

  test "should redirect edit when logged in as non-admin wrong user" do
    sign_in @other_user
    
    get edit_user_registration_path(@user)

    if !@user.admin?
      assert flash.empty?
      assert_redirected_to root_url
    end
  end

  test "should redirect update when logged in as wrong non-admin user" do
    sign_in @other_user
    
    patch user_registration_path, params: { user: { name: @user.name, email: @user.email } }

    if !@user.admin?
      assert flash.empty?
      assert_redirected_to root_url
    end
  end

  test "should not allow the admin attribute to be edited via the web" do
    sign_in @other_user
    assert_not @other_user.admin?
    
    patch user_registration_path, params: {
      user: {
        password: 'password',
        password_confirmation: 'password',
        admin: 1
      }
    }
    assert_not @other_user.reload.admin?
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete user_registration_path(@user)
    end
    assert_redirected_to new_user_session_url
  end

  # cant get other user's edit page now
  # test "should redirect destroy when logged in as a non-admin" do
  #   sign_in @other_user
  #   assert_no_difference 'User.count' do
  #     delete user_registration_path
  #   end
  #   assert_redirected_to users_path
  # end

  # test "should create user" do
  #   assert_difference('User.count') do
  #     post users_url, params: { user: { email: @user.email, name: @user.name } }
  #   end

  #   assert_redirected_to user_url(User.last)
  # end

  # test "should show user" do
  #   get user_url(@user)
  #   assert_response :success
  # end

  # test "should get edit" do
  #   get edit_user_url(@user)
  #   assert_response :success
  # end

  # test "should update user" do
  #   patch user_url(@user), params: { user: { email: @user.email, name: @user.name } }
  #   assert_redirected_to user_url(@user)
  # end

  # test "should destroy user" do
  #   assert_difference('User.count', -1) do
  #     delete user_url(@user)
  #   end

  #   assert_redirected_to users_url
  # end
end
