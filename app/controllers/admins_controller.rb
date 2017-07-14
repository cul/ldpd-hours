class AdminsController < ApplicationController
  skip_load_and_authorize_resource

  def show
    authorize! :edit, Location
    @locations = Location.all
  end
end
