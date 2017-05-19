require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  test "signing in" do
  	visit new_user_session

  	fill_in "Name", with: "Test Lib"
  	fill_in "Code", with: "Test code"

  	click_on "Create Library"
  	assert_text "Library successfully created"
  end
end