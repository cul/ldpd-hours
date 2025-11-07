shared_context 'login user' do
  include_context 'mock ldap'

  let(:logged_in_user) { User.create(uid: 'abc123', email: 'abc123@columbia.edu') }

  let(:saml_hash) do
    OmniAuth::AuthHash.new({ 'uid' => logged_in_user.uid, 'extra' => {} })
  end

  before :each do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:saml] = saml_hash
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:saml]
    entry = double('entry', name: 'Jane Doe', email: logged_in_user.email)
    allow(ldap).to receive(:find_by_uni).with(logged_in_user.uid).and_return(entry)
    visit '/sign_in'
  end
end

shared_context 'login admin' do
  include_context 'login user'

  before :each do
    logged_in_user.update_permissions(role: Permission::ADMINISTRATOR)
  end
end

shared_context 'login manager' do
  include_context 'login user'

  before :each do
    logged_in_user.update_permissions(role: Permission::MANAGER)
  end
end

shared_context 'mock ldap' do
  let(:ldap) { double('ldap') }

  before :each do
    allow(ldap).to receive(:find_by_uni) { nil }
    allow(Cul::LDAP).to receive(:new).and_return(ldap)
  end
end

shared_context 'mock admin user' do
  let(:logged_in_user) { double(User) }

  before do
    allow(logged_in_user).to receive(:administrator?).and_return(true)
    allow(logged_in_user).to receive(:manager?).and_return(false)
    allow(@request.env['warden']).to receive(:authenticate!).and_return(logged_in_user)
    allow(controller).to receive(:current_user).and_return(logged_in_user)
  end
end

shared_context 'mock manager user' do
  let(:logged_in_user) { double(User) }

  before do
    allow(logged_in_user).to receive(:administrator?).and_return(false)
    allow(logged_in_user).to receive(:manager?).and_return(true)
    allow(@request.env['warden']).to receive(:authenticate!).and_return(logged_in_user)
    allow(controller).to receive(:current_user).and_return(logged_in_user)
  end
end
