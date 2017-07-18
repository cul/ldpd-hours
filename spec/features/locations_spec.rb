require 'rails_helper'

describe "Locations" do
  include_context 'login admin'

  before(:each) do
    @location = FactoryGirl.create(:lehman)
  end

  it "visiting the index" do
    visit("/locations")

    expect(page).to have_css("ul")
  end

  it "adding a location" do

    visit new_location_path

    fill_in "Name", with: "Test Lib"
    fill_in "Code", with: "Test code"

    click_on "Create Location"
    expect(page).to have_content("Location successfully created")
  end

  it "should have a calendar on show page" do
    visit("/locations")
    first("li a").click
    expect(page).to have_css("tr")
  end
end
