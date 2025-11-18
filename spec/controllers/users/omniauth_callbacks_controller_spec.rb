require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  include_context 'mock ldap'

  let(:uid) { 'abc123' }
  let(:email) { 'abc123@columbia.edu' }
  let(:user) { FactoryBot.create(:user, uid: uid, email: email, name: 'Test User') }
  let(:controller_instance) { described_class.new }

  describe '#developer_uid' do
    before do
      allow(controller_instance).to receive(:params).and_return(ActionController::Parameters.new(uid: uid))
      allow(controller_instance).to receive(:sign_in_and_redirect)
      allow(controller_instance).to receive(:flash).and_return({})
      allow(controller_instance).to receive(:root_path).and_return('/')
      allow(controller_instance).to receive(:redirect_to)
    end

    context 'in development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      context 'when user exists' do
        it 'signs in the user' do
          expect(controller_instance).to receive(:sign_in_and_redirect).with(user, event: :authentication)
          controller_instance.developer_uid
        end
      end

      context 'when user does not exist' do
        it 'sets alert and redirects' do
          allow(controller_instance).to receive(:params).and_return(ActionController::Parameters.new(uid: 'nonexistent'))
          flash = {}
          allow(controller_instance).to receive(:flash).and_return(flash)

          controller_instance.developer_uid

          expect(flash[:alert]).to eq('Login attempt failed. Please try again.')
          expect(controller_instance).to have_received(:redirect_to).with('/')
        end
      end

      context 'when an error occurs' do
        it 'handles the error and redirects' do
          allow(User).to receive(:find_by).and_raise(StandardError.new('Database error'))
          flash = {}
          allow(controller_instance).to receive(:flash).and_return(flash)

          controller_instance.developer_uid

          expect(flash[:alert]).to eq('Authentication failed. Please try again.')
          expect(controller_instance).to have_received(:redirect_to).with('/')
        end
      end
    end

    context 'in non-development environment' do
      before do
        allow(Rails.env).to receive(:development?).and_return(false)
      end

      it 'returns without authenticating' do
        expect(controller_instance).not_to receive(:sign_in_and_redirect)
        controller_instance.developer_uid
      end
    end
  end

  describe '#columbia_cas' do
    let(:ticket) { '123456-abcdef' }
    let(:callback_url) { 'http://exampleurl.edu/auth/columbia_cas/callback' }

    before do
      allow(controller_instance).to receive(:user_columbia_cas_omniauth_callback_url).and_return(callback_url)
      allow(controller_instance).to receive(:request).and_return(double(params: { 'ticket' => ticket }))
      allow(controller_instance).to receive(:sign_in_and_redirect)
      allow(controller_instance).to receive(:flash).and_return({})
      allow(controller_instance).to receive(:root_path).and_return('/')
      allow(controller_instance).to receive(:redirect_to)
      allow(Omniauth::Cul::ColumbiaCas).to receive(:validation_callback)
        .with(ticket, callback_url)
        .and_return([uid, ['affil1', 'affil2']])
    end

    context 'when user exists' do
      it 'signs in the user' do
        expect(controller_instance).to receive(:sign_in_and_redirect).with(user, event: :authentication)
        controller_instance.columbia_cas
      end
    end

    context 'when user does not exist' do
      it 'sets alert and redirects' do
        flash = {}
        allow(controller_instance).to receive(:flash).and_return(flash)

        controller_instance.columbia_cas

        expect(flash[:alert]).to eq('Login attempt failed. Please try again.')
        expect(controller_instance).to have_received(:redirect_to).with('/')
      end
    end

    context 'when CAS validation fails' do
      it 'handles the error and redirects' do
        allow(Omniauth::Cul::ColumbiaCas).to receive(:validation_callback)
          .and_raise(StandardError.new('CAS error'))
        flash = {}
        allow(controller_instance).to receive(:flash).and_return(flash)

        controller_instance.columbia_cas

        expect(flash[:alert]).to eq('Authentication failed. Please try again.')
        expect(controller_instance).to have_received(:redirect_to).with('/')
      end
    end
  end
end
