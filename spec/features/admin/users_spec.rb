require 'rails_helper'

describe "Admin::Users" do

  before(:each) do
    @admin = User.create(uid: "def45678", role: "admin")
  end

  describe "visiting the index" do
    include_context 'login admin user'
    
    it "visiting the index" do
      visit("/admin/users")
    
      expect(page).to have_text("All Users")
    end
  end

  describe "add/delete users", js: true do
    include_context 'login admin user'

    it "adds a new user" do
      visit("/admin/users/new")

      fill_in "Enter Uni", with: "def456"
      select "Admin", from: "Role"

      click_button "Create User"
      expect(page).to have_content("User successfully added")
    end

    it "should delete a user" do
      visit("/admin/users")
      first("a i.fa-times").click
      expect(page.has_content?('def45678')).to eq(false)
    end

  end

  describe "add/remove superadmin status", js: true do
    include_context 'login admin user'

    it "should be able to update an admin to a superadmin" do
      visit("/admin/users")
      first("a i.fa-user-circle").click
      expect(first("a i.fa-user-circle")[:class]).to include 'admin-color'
    end

    it "should be able to change a superadmin back to an admin" do
      visit("/admin/users")
      first("a i.fa-user-circle").click
      first("a i.fa-user-circle").click
      expect(first("a i.fa-user-circle")[:class]).to_not include 'admin-color'
    end
  end


end