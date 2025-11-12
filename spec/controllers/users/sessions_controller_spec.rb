require 'rails_helper'

RSpec.describe Users::SessionsController, type: :controller do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe 'GET #new' do
  # Renders an auto-submitting form
  it 'responds with HTML' do
      get :new
      expect(response).to be_successful
      expect(response.content_type).to match(%r{text/html})
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { FactoryBot.create(:user) }

    context 'when user is signed in' do
      before do
        sign_in user
      end

      it 'signs out the user and redirects' do
        delete :destroy
        expect(controller.current_user).to be_nil
        expect(response).to redirect_to('/')
      end
    end

    context 'when user is not signed in' do
      it 'redirects to root' do
        delete :destroy
        expect(response).to redirect_to('/')
      end
    end
  end
end