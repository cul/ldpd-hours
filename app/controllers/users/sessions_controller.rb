class Users::SessionsController < Devise::SessionsController
  skip_before_action :authenticate_user!
  skip_load_and_authorize_resource

  def new_session_path(scope)
    new_user_session_path # this accomodates Users namespace of the controller
  end

  def omniauth_provider_key
    Rails.env == 'development' ? 'developer' : 'cas'
  end

  # GET /resource/sign_in
  def new
    render 'users/sessions/new'
    # if Rails.env == 'development'
    #   # Show the developer login form instead of redirecting
    #   @developer_auth_path = user_developer_omniauth_authorize_path
    #   render 'new'
    # else
    #   redirect_to user_cas_omniauth_authorize_path
    # end
  end
end
