class Api::V1::BaseController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
 
  protect_from_forgery with: :null_session
  before_action :destroy_session

  def record_not_found
    render json: { error: "404: ActiveRecord not found"} , status: 404
  end

  def destroy_session
    request.session_options[:skip] = true
  end

  private :record_not_found, :destroy_session
  
end
