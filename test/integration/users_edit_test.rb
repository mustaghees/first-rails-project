require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "unsuccessfull edit" do
    log_in_as(@user)
  
    get edit_user_path(@user)
    assert_template 'users/edit'

    patch user_path(@user), params: {
      user: { name: "", email: "foo@xyz", password: "132", password_confirmation: "asdfg" }
    }

    assert_template 'users/edit'
    assert_select '#errors li', count: 4
  end

  test "successfull edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    assert_nil session[:forwarding_url]

    name = "Mark Zuckerberg"
    email = "mark@facebook.com"

    patch user_path(@user), params: {
      user: { name: name, email: email, password: '', password_confirmation: '' }
    }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
