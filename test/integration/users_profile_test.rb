require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title("#{@user.name}'s Profile")
    assert_select 'h2', text: @user.name
    assert_select 'img.gravatar'
    assert_match (@user.posts.count/10).to_s, response.body
    assert_select 'div.pagination'
    @user.posts.paginate(page: 1, per_page: 10).each do |post|
      assert_match post.body, response.body
    end
  end
end
