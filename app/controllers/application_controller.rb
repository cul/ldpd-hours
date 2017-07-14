class ApplicationController < ActionController::Base
  include Devise::Controllers::Helpers

  protect_from_forgery with: :exception
  layout 'admin'

  # Authenticating and Authorizing each user for every request. Skipping this
  # steps for the few routes that are public.
  before_action :authenticate_user!
  load_and_authorize_resource
end
