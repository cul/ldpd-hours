require 'rails_helper'

describe "Admin::Users" do
  shared_context 'login admin user' do
    let(:uid) { 'abc123' }
    let(:email) { 'abc123@columbia.edu' }
    let(:saml_hash) do
      OmniAuth::AuthHash.new({ 'uid' => uid, 'extra' => {}, 'info' => {'email' => email} })
    end

    before :each do
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:saml] = saml_hash
      Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
      Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:saml]
      visit '/sign_in'
      User.find_by(uid: uid).update!(role: "superadmin")
    end
  end

  describe "visiting the index" do
    include_context 'login admin user'
    
    it "visiting the index" do
      visit("/admin/users")
    
      expect(page).to have_text("All Users")
    end
  end

  describe "adding and removing a user" do
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
      expect(page.has_content?('def456')).to eq(false)
    end
  end




end