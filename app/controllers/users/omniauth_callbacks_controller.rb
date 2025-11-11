class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  # See https://github.com/omniauth/omniauth/wiki/FAQ#rails-session-is-clobbered-after-callback-on-developer-strategy
  # The CAS login redirect to the columbia_cas callback endpoint AND the developer form submission to the
  # developer_uid callback do not send authenticity tokens, so we'll skip token verification for these actions.
  skip_before_action :verify_authenticity_token, only: [:columbia_cas, :developer_uid]
  skip_before_action :authenticate_user!
  skip_load_and_authorize_resource

  # POST /users/auth/developer_uid/callback
  def developer_uid
    puts "In developer_uid callback "
    return unless Rails.env.development?

    uid = params[:uid]
    current_user = User.find_by(uid: uid)
    puts 'Current user: ' + current_user.inspect

    if !current_user
      flash[:alert] = "Login attempt failed.  User #{uid} does not have an account."
      redirect_to root_path
      return
    end

    sign_in_and_redirect current_user, event: :authentication
  end

  def columbia_cas
    Rails.logger.info "Columbia CAS callback started"
    Rails.logger.info "Request params: #{request.params.inspect}"
    
    callback_url = user_columbia_cas_omniauth_callback_url
    uid, _affils = Omniauth::Cul::ColumbiaCas.validation_callback(request.params['ticket'], callback_url)
    Rails.logger.info "Received user_id: #{uid}, affils: #{_affils.inspect}"

    current_user = User.find_by(uid: uid)

    if !current_user
      Rails.logger.error "User not found for uid: #{uid}"
      flash[:alert] = "Login attempt failed.  Please try again."
      redirect_to root_path
      return
    end

    Rails.logger.info "Found user: #{current_user.uid}, signing in..."
    sign_in_and_redirect current_user, event: :authentication
  rescue => e
    Rails.logger.error "Columbia CAS callback error: #{e.message}"
    flash[:alert] = "Authentication failed. Please try again."
    redirect_to root_path
  end
end
