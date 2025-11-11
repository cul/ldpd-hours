class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!
  skip_load_and_authorize_resource

  def new_session_path(scope)
    new_user_session_path # this accomodates Users namespace of the controller
  end
end
