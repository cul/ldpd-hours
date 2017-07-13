require 'rails_helper'

describe "User management", js: true do
  let(:user) { User.create(uid: 'def456', email: "def456@columbia.edu") }

  describe "visiting index page" do
     include_examples 'not authorized when non-admin logged in' do
       let(:request) { visit "/admin/users" }
     end

    context 'when admin is logged in' do
      include_context 'login admin user'

      it "renders index page" do
        visit "/admin/users"
        expect(page).to have_text("All Users")
      end
    end
  end

  describe "adding users" do
    include_examples 'not authorized when non-admin logged in' do
      let(:request) { visit "/admin/users/new" }
    end

    context 'when admin is logged in' do
      include_context 'login admin user'

      before :each do
        entry = double('entry', name: 'John Doe', email: "def456@columbia.edu")
        allow(ldap).to receive(:find_by_uni).with('def456').and_return(entry)
      end

      it "can add a new user" do
        visit "/admin/users/new"

        fill_in "UNI", with: "def456"
        choose "user_permissions_admin_true"

        click_button "Create User"
        expect(page).to have_content("User successfully added")
        expect(page).to have_content("def456")
      end
    end
  end

  describe "deleting user" do
    include_examples 'not authorized when non-admin logged in' do
      let(:request) { visit "/admin/users/#{user.id}/edit" }
    end

    context 'when an admin is logged in' do
      include_context 'login admin user'

      it "can delete user from edit page" do
        visit "/admin/users/#{user.id}/edit"
        click_on "Delete User"
        expect(page).to have_content("User successfully deleted")
        expect(page).not_to have_content("def456")
      end

      it "can delete users from index page" do
        user
        visit "/admin/users"
        find("#delete_#{user.uid}").trigger('click')
        expect(page).not_to have_content 'def456'
      end
    end
  end

  describe "edit users permissions" do
    context "when an admin is logged in" do
      include_context 'login admin user'

      it "can add admin privilages" do
        visit edit_admin_user_path(user)
        choose "user_permissions_admin_true"
        click_button "Update User"
        expect(user.admin?).to eq true
      end

      it "can add location edit permissions" do
        butler = FactoryGirl.create(:butler)
        visit edit_admin_user_path(user)
        check 'Butler'
        click_button 'Update User'
        expect(page).to have_content 'User successfully updated'
        expect(user.reload.editable_locations).to eql [butler]
      end

      it "can change location edit permissions" do
        butler, lehman = FactoryGirl.create(:butler), FactoryGirl.create(:lehman)
        user.update_permissions(location_ids: [butler.id])
        visit edit_admin_user_path(user)
        check 'Lehman'
        uncheck 'Butler'
        click_button 'Update User'
        expect(page).to have_content 'User successfully updated'
        expect(user.reload.editable_locations).to eql [lehman]
      end

      it "can remove all edit and admin permissions" do
        user.update_permissions(location_ids: [FactoryGirl.create(:butler).id])
        visit edit_admin_user_path(user.id)
        uncheck "Butler"
        click_button 'Update User'
        expect(user.admin?).to eql false
        expect(user.editor?).to eql false
      end
    end
  end
end
