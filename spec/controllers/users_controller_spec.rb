require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:butler) { FactoryBot.create(:butler) }
  let(:lehman) { FactoryBot.create(:lehman) }

  let(:jane) { User.create(uid: 'xyz123', email: 'xyz123@columbia.edu') }

  # POST /users/:id
  describe "#create" do
    let(:uid) { 'xyz123' }

    include_context 'mock ldap'

    before :each do
      entry = double('entry', name: 'Jane Doe', email: "janedoe@columbia.edu")
      allow(ldap).to receive(:find_by_uni).with(uid).and_return(entry)
    end

    context "when admin logged in" do
      include_context 'mock admin user'

      it "creates user with admin privilages" do
        post :create, params: { user: { uid: uid, permissions: { role: 'administrator' } } }
        user = User.find_by(uid: uid)
        expect(user.administrator?).to eql true
      end

      it "creates user with editor privilages" do
        post :create, params: { user: { uid: uid, permissions: { role: 'editor', location_ids: [butler.id] } } }
        user = User.find_by(uid: uid)
        expect(user.permissions.count).to eql 1
        expect(user.permissions.first.subject_id).to eql butler.id
      end

      it "throws error if location id invalid" do
        post :create, params: { user: { uid: uid, permissions: { role: 'editor', location_ids: [1] } } }
        expect(controller.flash.to_h).to include('error' => 'Permissions one or more of the location ids given is invalid')
      end

      it "creates user with no permissions" do
        post :create, params: { user: { uid: uid, permissions: { role: 'editor' } } }
        user = User.find_by(uid: uid)
        expect(user.permissions.count).to eql 0
      end
    end

    context 'when manager logged in' do
      include_context 'mock manager user'

      it "creates user with editor privilages" do
        post :create, params: { user: { uid: uid, permissions: { role: 'editor', location_ids: [butler.id] } } }
        user = User.find_by(uid: uid)
        expect(user).not_to be nil
        expect(user.editor?).to be true
        expect(user.permissions.count).to eql 1
        expect(user.permissions.first.attributes).to include(
          'role' => 'editor', 'subject_class' => 'Location', 'subject_id' => butler.id
        )
      end

      it "forbids creating administrator" do
        post :create, params: { user: { uid: uid, permissions: { role: 'manager' } } }
        expect(response.status).to eql(403)
        expect(User.find_by(uid: uid)).to be nil
      end

      it "forbids creating manager" do
        post :create, params: { user: { uid: uid, permissions: { role: 'manager' } } }
        expect(response.status).to eql(403)
        expect(User.find_by(uid: uid)).to be nil
      end
    end
  end

  # PATCH /users/:id
  describe "#update" do
    context "when admin logged in" do
      include_context 'mock admin user'

      it "can updates user's admin status" do
        patch :update, params: { id: jane.id, user: { permissions: { role: 'administrator' } } }
        expect(jane.permissions.count).to eql 1
        expect(jane.permissions.first.attributes).to include(
          'role' => 'administrator', 'subject_class' => nil, 'subject_id' => nil
        )
      end

      it "adds editor privilages" do
        patch :update, params: { id: jane.id, user: { permissions: { role: 'editor', location_ids: [butler.id] } } }
        expect(jane.permissions.count).to eql 1
        expect(jane.permissions.first.attributes).to include(
          'role' => 'editor', 'subject_class' => 'Location', 'subject_id' => butler.id
        )
      end

      it "changes editor privilages" do
        jane.update_permissions(location_ids: [butler.id])
        patch :update, params: { id: jane.id, user: { permissions: { role: 'editor', location_ids: [lehman.id] } } }
        jane.reload
        expect(jane.permissions.count).to eql 1
        expect(jane.permissions.first.attributes).to include(
          'role' => 'editor', 'subject_class' => 'Location', 'subject_id' => lehman.id
        )
      end
    end

    context 'when manager logged in' do
      include_context 'mock manager user'

      it 'cannot update managers' do
        jane.update_permissions(role: 'manager')
        patch :update, params: { id: jane.id, user: { permissions: { role: 'editor' } } }
        expect(response.status).to eql(403)
      end

      it 'cannot update administrators' do
        jane.update_permissions(role: 'administrator')
        patch :update, params: { id: jane.id, user: { permissions: { role: 'editor' } } }
        expect(response.status).to eql(403)
       end

      it 'cannot make editors into managers' do
        jane.update_permissions(role: 'editor', location_ids: [butler.id])
        patch :update, params: { id: jane.id, user: { permissions: { role: 'manager' } } }
        expect(response.status).to eql(403)
        expect(controller.access_error_message).to include("Managers can only create Editors")
      end

      it 'cannot make editors into administrators' do
        jane.update_permissions(role: 'editor', location_ids: [butler.id])
        patch :update, params: { id: jane.id, user: { permissions: { role: 'administrator' } } }
        expect(response.status).to eql(403)
        expect(controller.access_error_message).to include("Managers can only create Editors")
      end
    end
  end

  # DELETE /users/:id
  describe '#destroy' do
    context "when administrator logged in" do
      include_context 'mock admin user'

      it "can delete editors" do
        jane.update_permissions(role: 'editor', location_ids: [butler.id])
        delete :destroy, params: { id: jane.id }
        expect(User.exists?(jane.id)).to be false
      end

      it "can delete managers" do
        jane.update_permissions(role: 'manager')
        delete :destroy, params: { id: jane.id }
        expect(User.exists?(jane.id)).to be false
      end

      it "can delete administators" do
        jane.update_permissions(role: 'administrator')
        delete :destroy, params: { id: jane.id }
        expect(User.exists?(jane.id)).to be false
      end
    end

    context 'when manager logged in' do
      include_context 'mock manager user'

      it "can delete editors" do
        jane.update_permissions(role: 'editor', location_ids: [butler.id])
        delete :destroy, params: { id: jane.id }
        expect(response.status).to eql(302) # redirects to index
        expect(User.exists?(jane.id)).to be false
      end

      it "cannot delete managers" do
        jane.update_permissions(role: 'manager')
        delete :destroy, params: { id: jane.id }
        expect(response.status).to eql(403)
        expect(User.exists?(jane.id)).to be true
      end

      it "cannot delete administators" do
        jane.update_permissions(role: 'administrator')
        delete :destroy, params: { id: jane.id }
        expect(response.status).to eql(403)
        expect(User.exists?(jane.id)).to be true
      end
    end
  end
end
