class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # Adding the line below so that if the auth endpoint POSTs to our cas endpoint, it won't
  # be rejected by authenticity token verification.
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  skip_before_action :verify_authenticity_token, only: :cas
  # skip_before_action :authenticate_user!, :verify_authenticity_token
  skip_load_and_authorize_resource

  def developer
    current_user ||= User.find_or_create_by(
      email: request.env["omniauth.auth"][:uid], provider: :developer)

    current_user.update(name: request.env["omniauth.auth"][:info][:name])

    sign_in_and_redirect current_user, event: :authentication
  end

  def app_cas_callback_endpoint
    "#{request.base_url}/users/auth/cas/callback"
  end

  def passthru
    puts "In passthru, request.path: #{request.path}"
    if Rails.env.development?
      # Let the developer strategy handle this automatically
      super
    else
      redirect_to Omniauth::Cul::Cas3.passthru_redirect_url(app_cas_callback_endpoint), allow_other_host: true
    end
  end

  # GET /users/auth/cas/callback
  def cas
    puts "In cas callback"
    user_id, affils = Omniauth::Cul::Cas3.validation_callback(request.params['ticket'], app_cas_callback_endpoint)
    puts "Received user_id: #{user_id}, affils: #{affils.inspect}"

    # Custom auth logic for your app goes here.
    # The code below is provided as an example.  If you want to use Omniauth::Cul::PermissionFileValidator,
    # to validate see the later "Omniauth::Cul::PermissionFileValidator" section of this README.
    #
    # if Omniauth::Cul::PermissionFileValidator.permitted?(user_id, affils)
    #   user = User.find_by(uid: user_id) || User.create!(
    #       uid: user_id,
    #       email: "#{user_id}@columbia.edu",
    #       password: Devise.friendly_token[0, 20] # Assign random string password, since the omniauth user doesn't need to know the unused local account password
    #   )
    #   sign_in_and_redirect user, event: :authentication # this will throw if @user is not activated
    # else
    #   flash[:error] = 'Login attempt failed'
    #   redirect_to root_path
    # end
  end
end
