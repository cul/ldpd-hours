require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  let(:lehman) { FactoryGirl.create(:lehman) }

  # PATCH /locations/:code
  describe '#update' do
    context "when administrator logged in" do
      include_context 'mock admin user'

      it "can update location code" do
        patch :update, params: { code: lehman.code, location: { code: 'new_a_code' } }
        lehman.reload
        expect(lehman.code).to eql 'new_a_code'
      end
    end

    context "when manager logged in" do
      include_context 'mock manager user'

      it "cannot update location code" do
        patch :update, params: { code: lehman.code, location: { code: 'new_m_code' } }
        lehman.reload
        expect(lehman.code).not_to eql 'new_m_code'
      end

      it "cannot update location name" do
        patch :update, params: { code: lehman.code, location: { name: 'NEW NAME' } }
        lehman.reload
        expect(lehman.name).not_to eql 'NEW NAME'
      end

      it "cannot update primary location"
    end
  end
end
