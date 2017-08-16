require 'rails_helper'

describe "Locations", type: :feature do
  let(:lehman) { FactoryGirl.create(:lehman) }
  let(:underbutler) { FactoryGirl.create(:underbutler) }
  let(:butler) { underbutler.primary_location }
  context 'when user without role logged in' do
    # initialize at least one library
    before { lehman }
    it "can visit index page" do
      visit("/locations")
      expect(page).to have_css("ul")
    end

    it "should have a calendar on show page" do
      visit("/locations")
      first("li a").click
      expect(page).to have_css("tr")
    end
    it "shows the primary and secondary locations" do
      visit("/locations/#{butler.code}")
      click_on underbutler.name
      expect(page).to have_css("h2", text: underbutler.name)
      expect(page).to have_css("h3", text: butler.name)
    end
  end

  context 'when administrator logged in' do
    include_context 'login admin'

    it "can add a new location" do
      visit new_location_path

      fill_in "Name", with: "Test Lib"
      fill_in "Code", with: "testco"
      check "Primary"
      click_on "Create Location"
      expect(page).to have_content("Location successfully created")
      expect(Location.count).to eql 1
      expect(Location.first.name).to eql 'Test Lib'
      expect(Location.first.code).to eql 'testco'
      expect(Location.first.primary).to eql true
    end

    it "displays error when missing code" do
      visit new_location_path

      fill_in "Name", with: "Test Lib"

      click_on "Create Location"
      expect(page).to have_content("Code can't be blank")
    end

    it "displays error when missing name" do
      visit new_location_path

      fill_in "Code", with: "testco"

      click_on "Create Location"
      expect(page).to have_content("Name can't be blank")
    end

    it "can delete location"

    it "can update location name" do
      visit edit_location_path(lehman.code)
      fill_in "Name", with: "NEW Lehman"
      click_on "Update Location"
      expect(page).to have_content("Location successfully updated")
      expect(lehman.reload.name).to eql 'NEW Lehman'
    end

    it "can update comments" do
      visit edit_location_path(lehman.code)
      fill_in "Comment", with: "Blah blah"
      click_on "Update Location"
      expect(page).to have_content("Location successfully updated")
      expect(lehman.reload.comment).to eql 'Blah blah'
    end

    it "can update primary location"
  end

  context 'when manager logged in' do
    include_context 'login manager'

    it "can update location comments" do
      visit edit_location_path(lehman.code)
      fill_in "Comment", with: "Blah blah"
      click_on "Update Location"
      expect(page).to have_content("Location successfully updated")
      expect(lehman.reload.comment).to eql 'Blah blah'
    end

    it "cannot delete lehman"

    it "cannot create a new location" do
      visit new_location_path
      expect(page).to have_content("Unauthorized")
    end
  end

  context 'when editor logged in' do
    include_context "login user"

    before :each do
      logged_in_user.update_permissions(role: Permission::EDITOR, location_ids: [lehman.id])
    end

    it "cannot edit another library" do
      visit edit_location_path(butler.code)
      expect(page).to have_content 'Unauthorized'
    end

    it "can edit lehman" do
      visit edit_location_path(lehman.code)
      expect(page).to have_content 'Lehman'
    end

    it "can edit lehman comment" do
      visit edit_location_path(lehman.code)
      fill_in 'Comment', with: "blah blah blah blah"
      click_on "Update Location"
      expect(page).to have_content 'Location successfully updated'
      expect(lehman.reload.comment).to eql 'blah blah blah blah'
    end

    it "cannot delete lehman"
  end
end
