class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include Devise::Controllers::Helpers
  layout 'admin'
end
