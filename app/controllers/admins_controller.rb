class AdminsController < ApplicationController
  authorize_resource :class => false
  layout "admin"

  def show
    @locations = Location.all
  end
end
