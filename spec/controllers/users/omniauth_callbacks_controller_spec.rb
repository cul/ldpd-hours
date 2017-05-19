require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  let(:uid) { 'abc123' }
  let(:email) { 'abc123@columbia.edu' }
  let(:saml_hash) do
    OmniAuth::AuthHash.new({ 'uid' => uid, 'extra' => {}, 'info' => {'email' => email} })
  end

  before :each do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:saml] = saml_hash
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.env["omniauth.auth"] = OmniAuth.config.mock_auth[:saml]
  end

  # GET :saml
  describe '#saml' do
    before :each do
      get :saml
    end

    it 'creates new user' do
      expect(User.count).to eq 1
    end

    it 'creates new user with correct details' do
      jane = User.first
      expect(jane.uid).to eq 'abc123'
      expect(jane.email).to eq 'abc123@columbia.edu'
    end
  end

end