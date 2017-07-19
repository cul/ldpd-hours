require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  let(:lehman) { FactoryGirl.create(:lehman) }

  describe 'PATCH /locations/:id' do
    context "when administrator logged in" do
      include_context 'mock admin user'

      it "cannot update location code" do
        patch :update, params: { id: lehman.id, location: { code: 'new_code' } }
        expect(lehman.code).not_to eql 'new_code'
      end
    end

    context "when manager logged in" do
      include_context 'mock manager user'

      it "cannot update location name" do
        patch :update, params: { id: lehman.id, location: { name: 'NEW NAME' } }
        expect(lehman.name).not_to eql 'NEW NAME'
      end

      it "cannot update primary location"
    end
  end
end
