require 'rails_helper'
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  subject { Ability.new(user) }
  let(:user) { FactoryGirl.create(:user, permissions: [role]) }
  let(:lehman) { FactoryGirl.create(:lehman) }
  let(:timetable) { Timetable.create(location: lehman) }

  shared_examples 'editor/manager permissions' do
    it { is_expected.not_to be_able_to(:create, Location) }
    it { is_expected.not_to be_able_to(:destroy, lehman) }
    it { is_expected.to     be_able_to(:update, lehman) }

    it { is_expected.to     be_able_to(:batch_edit, timetable) }
    it { is_expected.to     be_able_to(:batch_update, timetable) }
    it { is_expected.to     be_able_to(:exceptional_edit, timetable)}
  end

  context "when is a administrator" do
    let(:role) { Permission.new(role: Permission::ADMINISTRATOR) }

    it { is_expected.to be_able_to(:create, Location) }
    it { is_expected.to be_able_to(:update, Location.new) }
    it { is_expected.to be_able_to(:read, Location.new) }
    it { is_expected.to be_able_to(:destroy, Location.new) }

    it { is_expected.to be_able_to(:create, User.new) }
    it { is_expected.to be_able_to(:update, User.new) }
    it { is_expected.to be_able_to(:read, User.new) }
    it { is_expected.to be_able_to(:destroy, User.new) }

    it { is_expected.to be_able_to(:update, Timetable.new) }
    it { is_expected.to be_able_to(:batch_edit, Timetable.new) }
    it { is_expected.to be_able_to(:batch_update, Timetable.new) }
    it { is_expected.to be_able_to(:exceptional_edit, Timetable.new) }
  end

  context "when is a manager" do
    let(:role) { Permission.new(role: Permission::MANAGER) }
    let(:admin) {
      FactoryGirl.create(:user,
      uid: 'lmn123', email: "lmn123@columbia.edu",
      permissions: [Permission.new(role: Permission::ADMINISTRATOR)])
    }
    let(:manager) {
      FactoryGirl.create(:user,
      uid: 'lmn123', email: "lmn123@columbia.edu",
      permissions: [Permission.new(role: Permission::MANAGER)])
    }
    let(:editor) {
      FactoryGirl.create(:user,
      uid: 'def', email: "def123@columbia.edu",
      permissions: [Permission.new(role: Permission::EDITOR, subject_class: Location.to_s, subject_id: lehman.id)])
    }

    include_examples 'editor/manager permissions'
    it { is_expected.not_to be_able_to(:read, admin) }
    it { is_expected.not_to be_able_to(:update, admin) }
    it { is_expected.not_to be_able_to(:destroy, admin) }

    it { is_expected.not_to be_able_to(:read, manager) }
    it { is_expected.not_to be_able_to(:update, manager) }
    it { is_expected.not_to be_able_to(:destroy, manager) }

    it { is_expected.to     be_able_to(:read, editor) }
    it { is_expected.to     be_able_to(:update, editor) }
    it { is_expected.to     be_able_to(:destroy, editor) }

    it { is_expected.to     be_able_to(:batch_edit, Timetable) }
    it { is_expected.to     be_able_to(:exceptional_edit, Timetable) }
    it { is_expected.to     be_able_to(:batch_update, Timetable) }

    # Can CRUD users that don't have a role set
    it { is_expected.to     be_able_to(:create, User.new) }
    it { is_expected.to     be_able_to(:read, User.new) }
    it { is_expected.to     be_able_to(:update, User.new) }
    it { is_expected.to     be_able_to(:destroy, User.new) }
  end

  context "when is an editor" do
    let(:role) { Permission.new(role: Permission::EDITOR, subject_class: Location.to_s, subject_id: lehman.id) }

    include_examples 'editor/manager permissions'

    it { is_expected.not_to be_able_to(:create, User) }
    it { is_expected.not_to be_able_to(:update, User.new) }
    it { is_expected.not_to be_able_to(:destroy, User.new) }
    it { is_expected.not_to be_able_to(:show, User.new) }

    it { is_expected.not_to be_able_to(:batch_edit, Timetable.new) }
    it { is_expected.not_to be_able_to(:exceptional_edit, Timetable.new) }
    it { is_expected.not_to be_able_to(:batch_update, Timetable.new) }
  end
end
