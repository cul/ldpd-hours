class ErrorsController < ApplicationController
  include Gaffe::Errors

  layout 'public'

  # Make sure anonymous users can see the page
  skip_before_action :authenticate_user!
  skip_load_and_authorize_resource
end
