require 'rails_helper'

RSpec.describe Admin::UsersController, type: :controller do
  let(:butler) { FactoryGirl.create(:butler) }
  let(:lehman) { FactoryGirl.create(:lehman) }

  shared_context 'mock admin ability' do
    before do
      ability = Object.new
      ability.extend(CanCan::Ability)
      allow(controller).to receive(:current_ability).and_return(ability)
      ability.can :manage, :all
    end
  end

  # PATCH admin/users/:id
  describe "PATCH update" do
    context "when admin logged in" do
      include_context 'mock admin ability'

      let(:jane) { User.create(uid: 'abc123', email: 'abc123@columbia.edu') }

      it "updates user's admin status" do
        patch :update, params: { id: jane.id, user: { permissions: { admin: 'true' } } }
        expect(jane.permissions.count).to eql 1
        expect(jane.permissions.first.attributes).to include(
          'action' => 'manage', 'subject_class' => 'all', 'subject_id' => nil
        )
      end

      it "adds editor privilages" do
        patch :update, params: { id: jane.id, user: { permissions: { location_ids: [butler.id] } } }
        expect(jane.permissions.count).to eql 1
        expect(jane.permissions.first.attributes).to include(
          'action' => 'edit', 'subject_class' => 'Location', 'subject_id' => butler.id
        )
      end

      it "changes editor privilages" do
        jane.update_permissions(location_ids: [butler.id])
        patch :update, params: { id: jane.id, user: { permissions: { location_ids: [lehman.id] } } }
        jane.reload
        expect(jane.permissions.count).to eql 1
        expect(jane.permissions.first.attributes).to include(
          'action' => 'edit', 'subject_class' => 'Location', 'subject_id' => lehman.id
        )
      end
    end
  end

  # POST admin/users/:id
  describe "POST create" do
    context "when admin logged in" do
      let(:uid) { 'abc123' }

      include_context 'mock admin ability'
      include_context 'mock ldap'

      before :each do
        entry = double('entry', name: 'Jane Doe', email: "janedoe@columbia.edu")
        allow(ldap).to receive(:find_by_uni).with(uid).and_return(entry)
      end

      it "creates user with admin privilages" do
        post :create, params: { user: { uid: uid, permissions: { admin: 'true' } } }
        user = User.find_by(uid: uid)
        expect(user.admin?).to eql true
      end

      it "creates user with editor privilages" do
        post :create, params: { user: { uid: uid, permissions: { location_ids: [butler.id] } } }
        user = User.find_by(uid: uid)
        expect(user.permissions.count).to eql 1
        expect(user.permissions.first.subject_id).to eql butler.id
      end

      it "throws error if location id invalid" do
        post :create, params: { user: { uid: uid, permissions: { location_ids: [1] } } }
        expect(flash[:error]).to eq 'Permissions one or more of the location ids given is invalid'
      end

      it "creates user with no permissions" do
        post :create, params: { user: { uid: uid, permissions: { admin: 'false' } } }
        user = User.find_by(uid: uid)
        expect(user.permissions.count).to eql 0
      end
    end
  end
end
