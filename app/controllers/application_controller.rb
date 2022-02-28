class ApplicationController < ActionController::Base
  include Devise::Controllers::Helpers
  attr_reader :access_error_message

  protect_from_forgery with: :exception
  layout 'admin'

  # Authenticating and Authorizing each user for every request. Skipping this
  # steps for the few routes that are public.
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    @access_error_message = exception.message
    render '/errors/forbidden', status: 403
  end
end
