shared_context 'login admin' do
  include_context 'login user'

  before :each do
    User.find_by(uid: uid).update_permissions(role: Permission::ADMINISTRATOR)
  end
end

shared_context 'login manager' do
  before :each do
    User.find_by(uid: uid).update_permissions(role: Permission::MANAGER)
  end
end

shared_context 'login user' do
  include_context 'mock ldap'

  let(:uid) { 'abc123' }
  let(:email) { 'abc123@columbia.edu' }
  let(:saml_hash) do
    OmniAuth::AuthHash.new({ 'uid' => uid, 'extra' => {} })
  end

  before :each do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:saml] = saml_hash
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:saml]
    entry = double('entry', name: 'Jane Doe', email: email)
    allow(ldap).to receive(:find_by_uni).with(uid).and_return(entry)
    visit '/sign_in'
  end
end

shared_context 'mock ldap' do
  let(:ldap) { double('ldap') }

  before :each do
    allow(ldap).to receive(:find_by_uni) { nil }
    allow(Cul::LDAP).to receive(:new).and_return(ldap)
  end
end
