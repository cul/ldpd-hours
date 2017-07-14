class AdminsController < ApplicationController
  skip_load_resource

  def show
    @locations = Location.all
  end
end
