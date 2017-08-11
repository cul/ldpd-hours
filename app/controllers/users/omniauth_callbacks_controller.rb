class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Cul::Omniauth::Callbacks
  skip_before_action :authenticate_user!, :verify_authenticity_token
  skip_load_and_authorize_resource
  def developer
    current_user ||= User.find_or_create_by(email:request.env["omniauth.auth"][:uid])

    sign_in_and_redirect current_user, event: :authentication
  end
end
