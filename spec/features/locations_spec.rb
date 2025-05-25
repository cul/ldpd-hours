require 'rails_helper'

describe "Locations", type: :feature do
  let(:lehman) { FactoryBot.create(:lehman) }
  let(:underbutler) { FactoryBot.create(:underbutler) }
  let(:butler) { underbutler.primary_location }
  let(:duanereade) { FactoryBot.create(:duanereade, suppress_display: true) }

  context 'when user without role logged in' do
    # initialize at least one library
    before { lehman }
    it "can visit index page" do
      visit("/locations")
      expect(page).to have_css("ul")
    end

    it "should have a calendar on show page" do
      visit("/locations")
      # index page should list all open now locations
      expect(page.title).to include("Open Now")
      first("li.location-item a").click
      # show page should have a library name instead of Open Now general label
      expect(page.title).not_to include("Open Now")
      expect(page).to have_css("tr")
    end

    # This is a test targeting the Rails 6.1 change that switched `.where.not` behavior from NOR to NAND
    context "when an 'all' location and a suppressed location exist" do
      let!(:lehman) { FactoryBot.create(:lehman) }
      let!(:all_location) { FactoryBot.create(:all_location) }
      let!(:duanereade_location) { FactoryBot.create(:duanereade, suppress_display: true) }

      it "does not display the 'all' location and does not display suppressed locations", js: false do
        visit("/locations")
        expect(page).to have_content("Click on a location for its full schedule")
        expect(page).to have_content(lehman.name)
        expect(page).not_to have_content(all_location.name)
        expect(page).not_to have_content(duanereade_location.name)
      end
    end

    it "shows the primary and secondary locations" do
      visit("/locations/#{butler.code}")
      click_on underbutler.name
      expect(page.title).to include(butler.name)
      expect(page).to have_css("h2", text: underbutler.name)
      expect(page).to have_css("p", text: butler.name)
    end

    it "does not display suppressed locations", js: false do
      visit("/locations/#{duanereade.code}")
      expect(page.status_code).to eq(404)
      expect(page).to have_content("Location not found")
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

    it "displays suppressed locations", js: false do
      visit("/locations/#{duanereade.code}")
      expect(page).to have_content("Public display of this location is suppressed.")
    end

    it "can update suppress_display" do
      expect(duanereade.suppress_display).to be true
      visit edit_location_path(duanereade.code)
      uncheck "Suppress"
      click_on "Update Location"
      expect(page).to have_content("Location successfully updated")
      expect(duanereade.reload.suppress_display).to be false
    end
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

    it "displays suppressed locations", js: false do
      visit("/locations/#{duanereade.code}")
      expect(page).to have_content("Public display of this location is suppressed.")
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

    it "displays suppressed locations", js: false do
      visit("/locations/#{duanereade.code}")
      expect(page).to have_content("Public display of this location is suppressed.")
    end
  end
end
