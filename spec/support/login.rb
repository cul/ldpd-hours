shared_context 'login admin user' do
  let(:uid) { 'abc123' }
  let(:email) { 'abc123@columbia.edu' }
  let(:saml_hash) do
    OmniAuth::AuthHash.new({ 'uid' => uid, 'extra' => {}, 'info' => {'email' => email} })
  end

  before :each do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:saml] = saml_hash
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:saml]
    visit '/sign_in'
    User.find_by(uid: uid).update_permissions(admin: "true")
  end
end

shared_context 'login non-admin user' do
  let(:uid) { 'abc123' }
  let(:email) { 'abc123@columbia.edu' }
  let(:saml_hash) do
    OmniAuth::AuthHash.new({ 'uid' => uid, 'extra' => {}, 'info' => {'email' => email} })
  end

  before :each do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:saml] = saml_hash
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:saml]
    visit '/sign_in'
    User.find_by(uid: uid)
  end
end
