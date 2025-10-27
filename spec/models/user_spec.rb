require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#update_permissions' do
    let(:user) { User.create(uid: "xyz123", email: "xyz123@columbia.edu", name: "Xyz 123") }

    context "returns false" do
      it 'when role is invalid' do
        expect(user.update_permissions(role: "bunnies")).to be false
      end

      it 'when role is blank' do
        expect(user.update_permissions(role: '')).to be false
      end

      it 'when role is nil' do
        expect(user.update_permissions(role: nil)).to be false
      end

      it 'when location_ids are invalid' do
        expect(user.update_permissions(role: Permission::EDITOR, location_ids: [1])).to be false
      end
    end

    context 'when creating administrator role' do
      it 'creates correct permissions' do
        expect(user.update_permissions(role: Permission::ADMINISTRATOR)).to be true
        expect(user.administrator?).to be true
        expect(user.permissions.count).to eql 1
        expect(user.permissions.first.role).to eql Permission::ADMINISTRATOR
      end
    end

    context 'when creating manager role' do
      subject { user.update_permissions(role: Permission::MANAGER) }

      it 'creates correct permissions' do
        expect(subject).to be true
        expect(user.manager?).to be true
        expect(user.permissions.count).to eql 1
        expect(user.permissions.first.role).to eql Permission::MANAGER
      end

      it "creates correct permissions by overriding previous role" do
        user.update_permissions(role: Permission::ADMINISTRATOR)
        expect(subject).to be true
        expect(user.manager?).to be true
        expect(user.permissions.count).to eql 1
      end
    end

    context 'when creating editor roles' do
      let(:lehman) { FactoryBot.create(:lehman) }
      let(:butler) { FactoryBot.create(:butler) }

      it "creates correct editor roles" do
        expect(user.update_permissions(role: Permission::EDITOR, location_ids: [lehman.id])).to be true
        expect(user.permissions.count).to eql 1
        expect(user.editor?).to be true
      end

      it "adds new editor roles" do
        user.update_permissions(role: Permission::EDITOR, location_ids: [lehman.id])
        expect(user.update_permissions(role: Permission::EDITOR, location_ids: [lehman.id, butler.id])).to be true
        expect(user.permissions.count).to eql 2
        expect(user.editor?).to be true
        expect(user.editable_locations).to match [lehman, butler]
      end

      it "does not create roles if locations_ids are not provided" do
        expect(user.update_permissions(role: Permission::EDITOR)).to be true
        expect(user.permissions.count).to eql 0
        expect(user.editor?).to be false
      end
    end
    context 'when validating a new user' do
      let(:uid) { 'abcdef' }
      let(:email) { 'abcdef@mail.example.org' }
      let(:user_name) { 'Abc Def' }
      let(:ldap_entry) { instance_double(Cul::LDAP::Entry, uni: uid, email: email, name: user_name) }
      subject(:user) { User.new(uid: uid) }

      before do
        allow_any_instance_of(Cul::LDAP).to receive(:find_by_uni).with(uid).and_return(ldap_entry)
        user.valid?
      end

      it 'is valid' do
        expect(user.valid?).to be true
      end

      it 'assigns email from ldap' do
        expect(user.email).to eql(email)
      end

      it 'assigns name from ldap' do
        expect(user.name).to eql(user_name)
      end
    end
  end
end
