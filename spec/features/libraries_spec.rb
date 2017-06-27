require 'rails_helper'

describe "Libraries" do
  before(:each) do
    @library = FactoryGirl.create(:lehman)
  end

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

  it "should have a calendar on show page" do
    visit("/libraries")
    first("li a").click
    expect(page).to have_css("tr")
  end
end
