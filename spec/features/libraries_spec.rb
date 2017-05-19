require 'rails_helper'

describe "Libraries" do
  it "visiting the index" do
    visit("/libraries")
  
    expect(page).to have_css("ul")
  end

  it "adding a library" do
  	visit new_library_path

  	fill_in "Name", with: "Test Lib"
  	fill_in "Code", with: "Test code"

  	click_on "Create Library"
  	expect(page).to have_content("Library successfully created")
  end
end