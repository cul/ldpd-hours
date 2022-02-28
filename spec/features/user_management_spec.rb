require 'rails_helper'

describe "User management", type: :feature, js: true do
  let(:user) { User.create(uid: 'def456', email: "def456@columbia.edu") }
  let(:butler) { FactoryBot.create(:butler) }
  let(:lehman) { FactoryBot.create(:lehman) }

  shared_examples 'no user management permissions' do
    it 'cannot edit user' do
      visit edit_user_path(user.id)
      expect(page).to have_content 'Unauthorized'
    end

    it 'cannot view all users' do
      visit users_path(user.id)
      expect(page).to have_content 'Unauthorized'
    end
    it 'cannot add new user' do
      visit new_user_path
      expect(page).to have_content 'Unauthorized'
    end
  end

  context 'when user without any permissions logged in' do
    include_context 'login user'
    include_examples 'no user management permissions'
  end

  context 'when editor logged in' do
    include_context 'login user'

    before :each do
      logged_in_user.update_permissions(role: 'editor', location_ids: [butler.id])
    end

    include_examples 'no user management permissions'
  end

  context 'when manager logged in' do
    include_context 'login manager'

    it 'can update users with no role' do
      butler
      visit "/users/#{user.id}/edit"
      choose 'user_permissions_role_editor'
      check 'Butler'
      click_button "Update User"
      expect(page).to have_content("User successfully updated")
      expect(user.editable_locations).to eql [butler]
    end

    it 'can update editors' do
      user.update_permissions(role: 'editor', location_ids: [butler.id, lehman.id])
      visit "/users/#{user.id}/edit"
      uncheck 'Butler'
      click_button "Update User"
      expect(page).to have_content("User successfully updated")
      expect(user.editable_locations).to eql [lehman]
    end

    it 'only role option is editor' do
      visit "/users/#{user.id}/edit"

      expect(page).not_to have_css('input#user_permissions_role_administrator')
      expect(page).not_to have_css('input#user_permissions_role_manager')
    end
  end

  context 'when administrator logged in' do
    include_context 'login admin'

    before :each do
      entry = double('entry', name: 'John Doe', email: "def456@columbia.edu")
      allow(ldap).to receive(:find_by_uni).with('def456').and_return(entry)
    end

    it "renders index page" do
      visit "/users"
      expect(page).to have_text("All Users")
    end

    it "can add a new user" do
      visit "/users/new"

      fill_in "UNI", with: "def456"
      choose "user_permissions_role_administrator"

      click_button "Create User"
      expect(page).to have_content("User successfully added")
      expect(page).to have_content("def456")
    end

    it "can delete user from edit page" do
      visit "/users/#{user.id}/edit"
      click_on "Delete User"
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content("User successfully deleted")
      expect(page).not_to have_content("def456")
    end

    it "can delete users from index page" do
      user
      visit "/users"
      find("#delete_#{user.uid}").click
      page.driver.browser.switch_to.alert.accept
      expect(page).not_to have_content 'def456'
    end

    it "can add admin privilages" do
      visit edit_user_path(user)
      choose "user_permissions_role_administrator"
      click_button "Update User"
      expect(user.administrator?).to eq true
    end

    it "can add manager privilages" do
      visit edit_user_path(user)
      choose "user_permissions_role_manager"
      click_button "Update User"
      expect(user.manager?).to eq true
    end

    it "can add editor permissions" do
      butler
      visit edit_user_path(user)
      choose 'user_permissions_role_editor'
      check 'Butler'
      click_button 'Update User'
      expect(page).to have_content 'User successfully updated'
      expect(user.reload.editable_locations).to eql [butler]
    end

    it "can change editor permissions" do
      lehman = FactoryBot.create(:lehman)
      user.update_permissions(location_ids: [butler.id])
      visit edit_user_path(user)
      choose 'user_permissions_role_editor'
      check 'Lehman'
      uncheck 'Butler'
      click_button 'Update User'
      expect(page).to have_content 'User successfully updated'
      expect(user.reload.editable_locations).to eql [lehman]
    end

    it "can remove all edit and admin permissions" do
      user.update_permissions(location_ids: [butler.id])
      visit edit_user_path(user.id)
      choose 'user_permissions_role_editor'
      uncheck "Butler"
      click_button 'Update User'
      expect(page).to have_content 'User successfully updated'
      expect(user.reload.administrator?).to eql false
      expect(user.editor?).to eql false
    end
  end
end
