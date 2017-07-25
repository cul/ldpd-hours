class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Cul::Omniauth::Callbacks
  skip_before_action :authenticate_user!
  skip_load_and_authorize_resource
end
