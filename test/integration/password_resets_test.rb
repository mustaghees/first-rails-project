require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Invalid email
    post password_resets_path, params: {
      password_reset: { email: '' }
    }
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # Valid email
    post password_resets_path, params: {
      password_reset: { email: @user.email }
    }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # Password reset form
    user = assigns(:user)

    # Wrong email
    get edit_password_reset_path(user.reset_token, email: '')
    assert_redirected_to root_url

    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # Right email, wrong token
    get edit_password_reset_path('worng token', email: user.email)
    assert_redirected_to root_url

    # right combo
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
    
    # Invalid password and confirmation
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: {
        password: 'foobard',
        password_confirmation: 'juzzlaw'
      }
    }
    assert_select 'div#errors', count: 1

    # Empty password
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: { password: "", password_confirmation: "" }
    }
    assert_select 'div#errors'

    # Valid password & confirmation
    patch password_reset_path(user.reset_token), params: {
      email: user.email,
      user: { password: "foobaz123", password_confirmation: "foobaz123" }
    }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "reset expires" do
    get edit_user_password_path
    post user_password_path, params: {
      password_reset: { email: @user.email }
    }

    user = assigns(:user)
    user.update_attribute(:reset_password_sent_at, 3.hours.ago)

    patch user_password_path(user.reset_token), params: {
      email: user.email,
      user: { password: '123123123', password_confirmation: '123123123' }
    }

    assert_response :redirect
    follow_redirect!
    assert_match 'expired', response.body
  end
end
