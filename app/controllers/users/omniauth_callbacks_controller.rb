class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  # The CAS login redirect to the columbia_cas callback endpoint AND the developer form submission to the
  # developer_uid callback do not send authenticity tokens, so we'll skip token verification for these actions.
  skip_before_action :verify_authenticity_token, only: [:columbia_cas, :developer_uid]
  skip_before_action :authenticate_user!
  skip_load_and_authorize_resource

  # POST /users/auth/developer_uid/callback
  def developer_uid
    return unless Rails.env.development?

    uid = params[:uid]
    authenticate_and_sign_in(uid)
  rescue => e
    Rails.logger.error "Developer UID callback error: #{e.message}"
    handle_authentication_failure("Authentication failed. Please try again.")
  end

  def columbia_cas
    callback_url = user_columbia_cas_omniauth_callback_url
    uid, _affils = Omniauth::Cul::ColumbiaCas.validation_callback(request.params['ticket'], callback_url)
    Rails.logger.info "Received user_id: #{uid}, affils: #{_affils.inspect}"

    authenticate_and_sign_in(uid)
  rescue => e
    Rails.logger.error "Columbia CAS callback error: #{e.message}"
    handle_authentication_failure("Authentication failed. Please try again.")
  end

  private

  def authenticate_and_sign_in(uid)
    user = User.find_by(uid: uid)

    if user
      sign_in_and_redirect user, event: :authentication
    else
      Rails.logger.error "User not found for uid: #{uid}"
      handle_authentication_failure("Login attempt failed. Please try again.")
    end
  end

  def handle_authentication_failure(message)
    flash[:alert] = message
    redirect_to root_path
  end
end
