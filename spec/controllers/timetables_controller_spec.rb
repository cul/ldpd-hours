require 'rails_helper'

RSpec.describe TimetablesController, type: :controller do
  let(:butler) { FactoryGirl.create(:butler) }
  let(:lehman) { FactoryGirl.create(:lehman) }

  # POST /locations/:location_id/timetables/batch_update(.:format)
  describe '#batch_update' do
    describe 'when editor for lehman logged in' do
      let(:logged_in_user) { User.create(uid: 'abc123', email: 'abc123@columbia.edu', provider: 'saml') }

      before do
        logged_in_user.update_permissions(role: Permission::EDITOR, location_ids: [lehman.id])
        allow(@request.env['warden']).to receive(:authenticate!).and_return(logged_in_user)
        allow(controller).to receive(:current_user).and_return(logged_in_user)
      end

      it 'cannot update times for butler' do
        expect {
          post :batch_update, params: { location_code: butler.code }
        }.to raise_error CanCan::AccessDenied
      end

      it 'cannot visit set hours page' do
        expect {
          get :exceptional_edit, params: { location_code: butler.code }
        }.to raise_error CanCan::AccessDenied
      end

      it 'cannot visit batch hours page' do
        expect {
          get :batch_edit, params: { location_code: butler.code }
        }.to raise_error CanCan::AccessDenied
      end
    end

    describe 'when editor for butler logged in'
  end

  describe "#format_dates" do
    it "returns an array of date objects" do
      dates = ["2017-05-05", "2017-06-08"]
      expect(controller.send(:format_dates, {"dates" => dates}).first.class).to eql(Date)
    end
  end

  describe "#get_dates" do
    it "returns all mon-thurs when selected" do
      params = {"days" => "mon-thurs", "start_date" => "07/03/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(5)
    end

    it "returns all Sundays when selected" do
      params = {"days" => "Sunday", "start_date" => "07/02/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(2)
    end

    it "returns all saturdays when selected" do
      params = {"days" => "Saturday", "start_date" => "07/03/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(1)
    end

    it "returns all fridays when selected" do
      params = {"days" => "Friday", "start_date" => "07/03/2017", "end_date" => "07/10/2017"}
      result = controller.send(:get_dates, params)
      expect(result.count).to eql(1)
    end
  end
end
