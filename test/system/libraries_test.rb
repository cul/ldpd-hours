require "application_system_test_case"

class LibrariesTest < ApplicationSystemTestCase
  test "visiting the index" do
    visit libraries_url
  
    assert_selector "li"
  end

  test "adding a library" do
  	visit new_library_path

  	fill_in "Name", with: "Test Lib"
  	fill_in "Code", with: "Test code"

  	click_on "Create Library"
  	assert_text "Library successfully created"
  end
end
